VCC:=iverilog
C_OPTIONS:=
SUML:=vvp
SUML_OPTIONS:=-n
WAVE_SHOW:=gtkwave

VERILOG_SRC:=i2c.v test_i2c.v

.PHONY: default test_i2c clean #synthesis syn_dir

default:
	echo No test target.

clean:
	rm i2c i2c.vcd

test_i2c : i2c.vcd
	$(WAVE_SHOW) $^

%.vcd : %
	$(SUML) $(SUML_OPTIONS) $^

i2c: $(VERILOG_SRC)
	$(VCC) $(C_OPTIONS) -o $@ $^

