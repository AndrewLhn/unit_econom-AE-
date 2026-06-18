select sum(contribution_margin) as cm
from {{ ref('mart_geo_economics') }}
having round(sum(contribution_margin)::numeric, 2) != 660884.49