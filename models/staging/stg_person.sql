select
    businessentityid,
    firstname,
    lastname
from {{ source('raw', 'PERSON') }}