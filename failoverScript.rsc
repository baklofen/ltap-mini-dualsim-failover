{
	:global initTimeout 2
	:global connectTimeout 2
	:global minimumSignalLevel -99

	:global switchSIM do={
		:local simSlot [/system routerboard sim get sim-slot]

		:if ($simSlot="down") do={
			:log info message="Switching to \"up\" sim slot (Vodafone)"
			/system routerboard sim set sim-slot=up
		} else={
			:log info message="Switching to \"down\" sim slot (Kyivstar)"
			/system routerboard sim set sim-slot=down
		}
	}

	:global initialize do={
		:log info message="init start"
		:global initTimeout

		:local i 0
		:while ($i < $initTimeout) do={
			:if ([:len [/interface lte find ]] > 0) do={
				:return true
			}			
			:set $i ($i+1)
			:delay 1s
		}

		:return false
	}

	:global connect do={
		:log info message="connect start"
		:global connectTimeout

		:local $i 0
		:while ($i < $connectTimeout) do={
			:if ([/interface lte get [find name="lte1"] running] = true) do={
				:return true
			}
			:set $i ($i+1)
			:delay 1s
		}

		:return false
	}

	:if ([$initialize] = true) do={
		:if ([$connect] = true) do={
			:local info [/interface lte info lte1 once]
			:if ($info->"rssi" < $minimumSignalLevel) do={
				:log info message="Current RSSI ".$info->"rssi"." < ".$minimumSignalLevel.". Trying to switch active sim slot."
				$switchSIM
			}
		} else={
			:log info message="GSM network is not connected. Trying to switch active sim slot."
			$switchSIM
		}
	} else={
		:log info message="LTE modem did not appear, trying power-reset"
		/system routerboard usb power-reset duration=5s
	}		
}
