WITH
    service_request_indices AS (
      SELECT
        ('ServiceRequest-' || service_requests.id)::text AS id,
        'ServiceRequest'::text AS searchable_type,
        service_requests.id::int AS searchable_id,
        (
          coalesce(service_requests.raw_data->>'description'::text, '') || ' ' ||
          coalesce(service_requests.raw_data->>'service_name'::text, '') || ' ' ||
          coalesce(cities.slug::text, '')
        )::text AS content
      FROM service_requests
        LEFT JOIN cities ON cities.id = service_requests.city_id
  )

SELECT id, searchable_type, searchable_id, content FROM service_request_indices
