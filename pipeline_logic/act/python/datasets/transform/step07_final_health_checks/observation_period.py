from transforms.api import transform_df, Input, Output, Check
from transforms import expectations as E
from act.omop_schemas import complete_domain_schema_dict

domain = "observation_period"
# Get complete schema for this OMOP domain as an OrderedDict
complete_schema = complete_domain_schema_dict[domain]
# Cast to regular dictionary and convert column names to lowercase
complete_schema = {k.lower(): v for k, v in complete_schema.items()}
schema_expectation = E.schema().contains(complete_schema)
all_checks = [
    Check(E.primary_key('observation_period_id'), 'Valid primary key', on_error='FAIL'),
    Check(schema_expectation, 'Dataset includes expected OMOP columns with proper types', on_error='WARN'),
    Check(E.col('observation_period_id').non_null(), 'observation_period_id column contains null', on_error='WARN'),
    Check(E.col('person_id').non_null(), 'person_id column contains null', on_error='WARN'),
    Check(E.col('observation_period_start_date').non_null(), 'observation_period_start_date column contains null', on_error='WARN'),
    Check(E.col('observation_period_end_date').non_null(), 'observation_period_end_date column contains null', on_error='WARN'),
    Check(E.col('period_type_concept_id').non_null(), 'period_type_concept_id column contains null', on_error='WARN'),
]


@transform_df(
    Output('/UNITE/Data Ingestion & OMOP Mapping/Source Data Model: ACT/Site 411/final/observation_period'),
    my_input=Input(
        '/UNITE/Data Ingestion & OMOP Mapping/Source Data Model: ACT/Site 411/transform/06 - id generation/observation_period',
        checks=all_checks
    ),
)
def compute_function(my_input):
    return my_input
