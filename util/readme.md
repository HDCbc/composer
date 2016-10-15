This directory contains scripts for managing batch queries.

The python script `schedule_jobs.py` is used to make a request on the hub route `scheduled_jobs/batch_query`. It triggers to hub to run queres that match the parameters provided.

The parameters must be provided must be in a json file containing the following:

* A user in the query_composer database that is associated with each query.
* A list of endpoints to run the queries on.
* A list of queries to execute. Queries are identified by the *title* field.

E.g.:
{
    "username": "maintenance",
    "endpoint_names": [
        "00"
    ],
    "query_titles": [
        "HDC-0001"
    ]
}
