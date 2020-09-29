        SELECT o.order_code,
        o.lg_zone_id ,
        o.lg_city_id ,
        o.rider_accepting_time_in_seconds,
        o.to_vendor_time_in_seconds,
        o.at_vendor_time_in_seconds,
        o.to_customer_time_in_seconds,
        o.at_customer_time_in_seconds,
        o.order_placed_at_local ,
        o.order_promised_delivery_at_local ,
        o.order_delivered_at_local,
        COALESCE(o.to_vendor_time_in_seconds,0)
        +COALESCE(o.at_vendor_time_in_seconds,0)
        +COALESCE(o.to_customer_time_in_seconds,0)
        +COALESCE(o.at_customer_time_in_seconds,0) AS from_assigned_to_completion,
        GREATEST(0,COALESCE(o.vendor_lateness_in_seconds ,0)) AS rider_lateness_in_seconds,
        o.actual_delivery_time_in_seconds,
        o.assumed_actual_prep_time_in_seconds   AS prep_time,
        ----Additional----
        --o.rider_dispatched_at_local  ,
        --o.rider_accepted_at_local ,
        --o.rider_notified_at_local ,
        --o.rider_near_restaurant_at_local ,
        ---o.rider_picked_up_at_local ,
        --o.rider_dropped_off_at_local ,
        --o.rider_near_customer_at_local , 
        --o.vendor_late_time_in_seconds,
        o.vendor_lateness_in_seconds,
        z.name as zone_name,
        z.shape,
        z.boundaries 
        FROM (SELECT * FROM pandata.lg_orders o WHERE
              o.rdbms_id = 17 and created_date_local >=  '2020-04-15') o 
        LEFT JOIN (SELECT * FROM `pandata.lg_zones` WHERE rdbms_id = 17 ) z 
        on z.id  = o.lg_zone_id  and z.lg_city_id  = o.lg_city_id )zone
        ON odr.order_id  = zone.order_code 
    LEFT JOIN 
    (SELECT vendor_code, 
      city_id, 
      city_name,
      chain_code
      from `pandata.dim_vendors` 
      where rdbms_id = 17 ) v 
    on odr.vendor_id  = v.vendor_code 
    WHERE country ='TH'