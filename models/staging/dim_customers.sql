select
    customerid,
    firstname,
    lastname,
    emailaddress,
    city,
    countryregionname,
    gender,
    education,
    occupation,
    yearlyincome
from {{ ref('stg_customer_enriched') }}