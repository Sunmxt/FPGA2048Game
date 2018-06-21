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
	rm i2c i2c.vcd ssd1780 ssd1780.vcd random random.vcd

test_random: random.vcd
	$(WAVE_SHOW) $^

test_i2c : i2c.vcd
	$(WAVE_SHOW) $^

test_ssd1780 : ssd1780.vcd
	$(WAVE_SHOW) $^

test_testdisplay : testdisplay.vcd
	$(WAVE_SHOW) $^

%.vcd : %
	$(SUML) $(SUML_OPTIONS) $^

i2c: $(VERILOG_SRC)
	$(VCC) $(C_OPTIONS) -o $@ $^

ssd1780: ssd1780.v test_ssd1780.v i2c.v
	$(VCC) $(C_OPTIONS) -o $@ $^

random: random.v test_random.v
	$(VCC) $(C_OPTIONS) -o $@ $^

testdisplay : test_testdisplay.v testdisplay.v ssd1780.v i2c.v
	$(VCC) $(C_OPTIONS) -o $@ $^
    
