import os
import base64
import json
from string import Template
from slack_sdk import WebClient
from google.cloud import secretmanager

SLACK_CHANNEL = "#X"

BLOCK_TEMPLATE = """
[
    {
		"type": "header",
		"text": {
			"type": "plain_text",
			"text": "A new security finding has been identified"
		}
	},
    {
        "type": "section",
        "text": {
            "type": "mrkdwn",
            "text": "*Link*: <${WEBLINK}|${CATEGORY}>\n*Project*: ${PROJECT_DISPLAY_NAME}\n*Severity*: *${SEVERITY}* ${SEVERITY_EMOJI}\n*State*: ${STATE}\n*When*: ${TIMESTAMP}"
        },
        "accessory": {
            "type": "button",
            "text": {
                "type": "plain_text",
                "text": "View in Cloud Console"
            },
            "value": "click_view",
            "url": "${WEBLINK}",
            "action_id": "button-view"
        }
    },
    {
        "type": "section",
        "text": {
            "type": "mrkdwn",
            "text": "*Explanation:*\n${EXPLANATION}"
        }
    },
    {
        "type": "section",
        "text": {
            "type": "mrkdwn",
            "text": "*Recommendation:*\n${RECOMMENDATION}"
        }
    },
    {
        "type": "section",
        "text": {
            "type": "mrkdwn",
            "text": "*Instructions:*\n${INSTRUCTION}"
        }
    },
    {
        "type": "divider"
    }
]
"""

def slack_token() -> str:
    secret_manager_client = secretmanager.SecretManagerServiceClient()
    secret_name = os.environ.get('SECRET_NAME')
    response = secret_manager_client.access_secret_version(request={"name": secret_name})
    token = response.payload.data.decode("UTF-8")
    return token

def blocks(data: dict) -> dict:
    finding = data.get('finding', {})
    mapping = {
        "WEBLINK": weblink(finding.get('name')),
        "CATEGORY": finding.get('category'),
        "PROJECT_DISPLAY_NAME": data.get("resource", {}).get("projectDisplayName"),
        "SEVERITY": finding.get('severity'),
        "SEVERITY_EMOJI": ":warning:" if "HIGH" in finding.get('severity') else "",
        "STATE": finding.get('state'),
        "TIMESTAMP": finding.get("createTime"),
        "EXPLANATION": escape_block_text(finding.get("sourceProperties", {}).get("Explanation")),
        "RECOMMENDATION": escape_block_text(finding.get("sourceProperties", {}).get("Recommendation")),
        "INSTRUCTION": escape_block_text(finding.get("sourceProperties", {}).get("ExceptionInstructions")),
    }
    return Template(BLOCK_TEMPLATE).safe_substitute(mapping)

def escape_block_text(text: str) -> str:
    text = json.dumps(text) \
        .replace("\\", "") \
        .removeprefix('"') \
        .removesuffix('"') \
        .replace('"', '`')
    return text

def weblink(finding_name: str) -> str:
    # the input looks like "organizations/<ID>/sources/12248410086678420485/findings/210c375c4e4444b89ff57a55c1f54beb"
    parts = finding_name.split('/')
    mapping = {
        "organization_id": parts[1],
        "source_id": parts[3],
        "finding_id": parts[5],
    }
    url_template = ("https://console.cloud.google.com/security/command-center/findings"
                    "?organizations/${organization_id}/sources/${source_id}/"
                    "findings/${finding_id}=,true&orgonly=true"
                    "&organizationId=${organization_id}&supportedpurview=organizationId"
                    "&view_type=vt_finding_type&vt_finding_type=All"
                    "&resourceId=organizations/${organization_id}/sources/${source_id}/"
                    "findings/${finding_id}")
    return Template(url_template).safe_substitute(mapping)


def send_slack_chat_notification(event, context) -> None:
    data = json.loads(base64.b64decode(event['data']).decode('utf-8'))
    client = WebClient(token=slack_token())
    client.chat_postMessage(channel=SLACK_CHANNEL, text="Identified a new security finding", blocks=blocks(data))
