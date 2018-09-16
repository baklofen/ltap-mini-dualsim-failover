{
	# Setup and read current values, "up" SIM slot will be used for reserve, "down" for main network
	:global simSlot [/system routerboard sim get sim-slot]
	:global initTimeout 60
	:global connectTimeout 60
	:global minimumSignalLevel -99

	# Wait for LTE modem to initialize for maximum "initTimeout" seconds
	:local i 0
	:local modemInitialized false
	:while ($i <  $initTimeout) do={
		:foreach n in=[/interface lte find] do={
			:set $modemInitialized true
		}
		:if ($modemInitialized=true) do={
			:set $i $initTimeout
		}
		:set $i ($i+1)
		:delay 1s
	}

	# Check if LTE modem is initialized, or try power-reset the modem
	:if ($modemInitialized=true) do={
		# Wait for LTE interface to connect to mobile network for maximum "connectTimeout" seconds
		:local isConnected false
		:local info [/interface lte info lte1 once]
		:set $i 0
		:while ($i < $connectTimeout) do={
			:if ([/interface lte get [find name="lte1"] running]=true) do={
				:set $isConnected true
				:set $i $connectTimeout
			}
			:set $i ($i+1)
			:delay 1s
		}
		# Check if LTE is connected, or GSM signal is below threshold
		if ($isConnected = false || $info->"rssi" < $minimumSignalLevel do={
			# Check which SIM slot is used
			:if ($simSlot="down") do={
				:log info message="Switching to SIM UP (Vodafone)"
				/system routerboard sim set sim-slot=up
			} else={
				:log info message="Switching to SIM DOWN (Kyivstar)"
				/system routerboard sim set sim-slot=down
			}
		}
	} else={
		:log info message="LTE modem did not appear, trying power-reset"
		/system routerboard usb power-reset duration=5s
	}
}
