# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "INPUT_Q_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INPUT_STR_MAXLEN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "M_AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "M_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RAM_START" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TOKEN_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.INPUT_Q_SIZE { PARAM_VALUE.INPUT_Q_SIZE } {
	# Procedure called to update INPUT_Q_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INPUT_Q_SIZE { PARAM_VALUE.INPUT_Q_SIZE } {
	# Procedure called to validate INPUT_Q_SIZE
	return true
}

proc update_PARAM_VALUE.INPUT_STR_MAXLEN { PARAM_VALUE.INPUT_STR_MAXLEN } {
	# Procedure called to update INPUT_STR_MAXLEN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INPUT_STR_MAXLEN { PARAM_VALUE.INPUT_STR_MAXLEN } {
	# Procedure called to validate INPUT_STR_MAXLEN
	return true
}

proc update_PARAM_VALUE.M_AXI_ADDR_WIDTH { PARAM_VALUE.M_AXI_ADDR_WIDTH } {
	# Procedure called to update M_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_AXI_ADDR_WIDTH { PARAM_VALUE.M_AXI_ADDR_WIDTH } {
	# Procedure called to validate M_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.M_AXI_DATA_WIDTH { PARAM_VALUE.M_AXI_DATA_WIDTH } {
	# Procedure called to update M_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_AXI_DATA_WIDTH { PARAM_VALUE.M_AXI_DATA_WIDTH } {
	# Procedure called to validate M_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.RAM_START { PARAM_VALUE.RAM_START } {
	# Procedure called to update RAM_START when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RAM_START { PARAM_VALUE.RAM_START } {
	# Procedure called to validate RAM_START
	return true
}

proc update_PARAM_VALUE.TOKEN_WIDTH { PARAM_VALUE.TOKEN_WIDTH } {
	# Procedure called to update TOKEN_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TOKEN_WIDTH { PARAM_VALUE.TOKEN_WIDTH } {
	# Procedure called to validate TOKEN_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.M_AXI_ADDR_WIDTH { MODELPARAM_VALUE.M_AXI_ADDR_WIDTH PARAM_VALUE.M_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.M_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.M_AXI_DATA_WIDTH { MODELPARAM_VALUE.M_AXI_DATA_WIDTH PARAM_VALUE.M_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.M_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.TOKEN_WIDTH { MODELPARAM_VALUE.TOKEN_WIDTH PARAM_VALUE.TOKEN_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TOKEN_WIDTH}] ${MODELPARAM_VALUE.TOKEN_WIDTH}
}

proc update_MODELPARAM_VALUE.INPUT_Q_SIZE { MODELPARAM_VALUE.INPUT_Q_SIZE PARAM_VALUE.INPUT_Q_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INPUT_Q_SIZE}] ${MODELPARAM_VALUE.INPUT_Q_SIZE}
}

proc update_MODELPARAM_VALUE.INPUT_STR_MAXLEN { MODELPARAM_VALUE.INPUT_STR_MAXLEN PARAM_VALUE.INPUT_STR_MAXLEN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INPUT_STR_MAXLEN}] ${MODELPARAM_VALUE.INPUT_STR_MAXLEN}
}

proc update_MODELPARAM_VALUE.RAM_START { MODELPARAM_VALUE.RAM_START PARAM_VALUE.RAM_START } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RAM_START}] ${MODELPARAM_VALUE.RAM_START}
}

