/*
 * STMicroelectronics SW Virtual Gyroscope Sensor Class
 *
 * Copyright 2015-2016 STMicroelectronics Inc.
 * Author: Denis Ciocca - <denis.ciocca@st.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 */

#include <fcntl.h>
#include <assert.h>
#include <signal.h>

#include "SWVirtualGyroscope.h"

SWVirtualGyroscope::SWVirtualGyroscope(const char *name, int handle) :
	SWSensorBaseWithPollrate(name, handle, STMSensorType::GYROSCOPE,
			true, false, true, false)
{
#if (CONFIG_ST_HAL_ANDROID_VERSION > ST_HAL_KITKAT_VERSION)
	//sensor_t_data.stringType = SENSOR_STRING_TYPE_GYROSCOPE;
	info.flags |= SENSOR_FLAG_CONTINUOUS_MODE;
#endif /* CONFIG_ST_HAL_ANDROID_VERSION */

	info.maxRange = 0;

	dependencies_type_list[SENSOR_DEPENDENCY_ID_0] = STMSensorType::INTERNAL_LIB_TYPE;
	id_sensor_trigger = SENSOR_DEPENDENCY_ID_0;
}

SWVirtualGyroscope::~SWVirtualGyroscope()
{

}

void SWVirtualGyroscope::ProcessData(SensorBaseData *data)
{
	memcpy(sensor_event.data, data->processed, SENSOR_DATA_3AXIS * sizeof(float));
	sensor_event.timestamp = data->timestamp;

	SWSensorBaseWithPollrate::WriteDataToPipe(data->pollrate_ns);
	SWSensorBaseWithPollrate::ProcessData(data);
}
