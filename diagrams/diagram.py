from diagrams import Cluster, Diagram, Edge  # type: ignore
from diagrams.custom import Custom
from diagrams.generic.blank import Blank
from diagrams.k8s.compute import Pod
from diagrams.k8s.infra import Master, Node
from diagrams.onprem.analytics import Dbt
from diagrams.onprem.database import PostgreSQL
from diagrams.onprem.iac import Terraform
from diagrams.onprem.workflow import Airflow

with Diagram(
    filename="cluster",
    direction="TB",
    show=False,
    node_attr={"imagepos": "c"},
):
    terraform = Terraform("Terraform")
    blank = Blank()

    with Cluster(
        "cluster",
        graph_attr={
            "labeljust": "c",
            "fontsize": "14",
        },
    ):
        kubernetes = Custom("", icon_path="./diagrams/kubernetes.png")

        with Cluster(
            "Node 1 (component: airbyte)",
            graph_attr={"labeljust": "c", "fontsize": "14"},
        ):
            node_1 = Node(width="0.7", height="0.7")
            airbyte = Custom("Airbyte", "./diagrams/airbyte.png", labelloc="t")
            kubernetes >> Edge(color="#E5F5FD") >> airbyte

        with Cluster(
            "Node 2 (component: airflow)",
            graph_attr={"labeljust": "c", "fontsize": "14"},
        ):
            node_2 = Node(width="0.7", height="0.7")

            with Cluster("Workflow Orchestration"):
                # pod = Pod(width="0.7", height="0.7")
                airflow = Airflow("Airflow", labelloc="t")
                dbt = Dbt("transformations")
                airflow >> dbt

        with Cluster(
            "Node 3 (component: jobs)",
            graph_attr={"labeljust": "c", "fontsize": "14"},
        ):
            node_3 = Node(width="0.7", height="0.7")
            with Cluster(
                "Ephemeral pods",
                graph_attr={"labeljust": "c", "fontsize": "14"},
            ):
                (
                    Pod(width="0.7", height="0.7")
                    >> Edge(color="#ECE8F6")
                    >> Pod(width="0.7", height="0.7")
                )

        with Cluster(
            "Control Plane",
            graph_attr={
                "labeljust": "c",
                "fontsize": "14",
            },
        ) as control_plane:
            master = Master(width="0.7", height="0.7")
            master >> Edge(color="#E5F5FD") >> kubernetes
            master >> [node_1, node_2, node_3]
            terraform >> Edge(color="#E5F5FD") >> master

    with Cluster(
        "Metadata", graph_attr={"labeljust": "c", "labelloc": "b", "fontsize": "14"}
    ):
        airflow_db = PostgreSQL("Airflow")
        airbyte_db = PostgreSQL("Airbyte")
        (
            airflow
            >> Edge(style="dotted")
            >> blank
            >> Edge(style="dotted")
            << blank
            << Edge(style="dotted")
            << airflow_db
        )
        airbyte >> Edge(style="dotted") << airbyte_db

    with Cluster(
        "Databases", graph_attr={"labeljust": "c", "labelloc": "b", "fontsize": "14"}
    ):
        clients = PostgreSQL("Clients")
        warehouse = PostgreSQL("Warehouse")
        (
            warehouse
            >> Edge(color="brown", style="bold")
            >> dbt
            >> Edge(color="brown", style="bold")
            >> warehouse
        )
        (
            clients
            >> Edge(color="brown", style="bold")
            >> airbyte
            >> Edge(color="brown", style="bold")
            >> warehouse
        )
