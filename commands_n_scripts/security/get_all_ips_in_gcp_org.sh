PROJECTS=$(gcloud projects list --format="value(name)")

for project in $PROJECTS
do
    if [[ $(gcloud services list --project $project --format="table(NAME)" | sed '1d') =~ "compute.googleapis.com" ]];then
       echo $project
       gcloud compute addresses list --project $project --global
    fi
done
