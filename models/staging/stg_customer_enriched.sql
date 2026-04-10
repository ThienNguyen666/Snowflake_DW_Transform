with base as (
    select
        c.customerid,
        c.personid,

        p.firstname,
        p.lastname,

        vc.emailaddress,
        vc.city,
        vc.countryregionname,

        demo.gender,
        demo.education,
        demo.occupation,
        demo.yearlyincome

    from {{ ref('stg_customer') }} c

    left join {{ ref('stg_person') }} p
        on c.personid = p.businessentityid

    left join {{ source('raw', 'VINDIVIDUALCUSTOMER') }} vc
        on c.personid = vc.businessentityid

    left join {{ source('raw', 'VPERSONDEMOGRAPHICS') }} demo
        on c.personid = demo.businessentityid
)

select *
from (
    select *,
        row_number() over (
            partition by customerid
            order by customerid
        ) as rn
    from base
)
where rn = 1