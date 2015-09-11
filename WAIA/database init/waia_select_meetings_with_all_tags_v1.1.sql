select  a.meeting_name,
		a.location_name,
		a.address1,
		a.address2,
		a.quadrant,
		a.city,
		a.state,
		a.postal_code,
		a.instructions,
		a.day,
		TIME_FORMAT(a.time, "%h:%i %p") as time,
		GROUP_CONCAT(c.description order by c.category_id, c.order_id) as `meeting_tags` 

from  	waia.meetings a,    
		waia.meeting_tags b,    
		waia.meeting_tag_types c 

where   a.meeting_id_pk = b.meeting_id_pk and   
		b.meeting_tag_type_id_pk = c.meeting_tag_type_id_pk 

group by a.meeting_id_pk

order by a.day_order,
		 a.state,
		 a.quadrant,
		 a.city,
		 a.time_order,
		 a.time;