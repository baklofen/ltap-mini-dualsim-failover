# ltap-mini-dualsim-failover
RouterOS script that changes active sim slot if GSM network is unreachable or running low signal (&lt;-99 dBm)

Currenly in testing and developing.

Original script: https://wiki.mikrotik.com/wiki/Dual_SIM_Application

# Usage
/system scheduler add interval=3m on-event=failoverScript name=SIM Switch
