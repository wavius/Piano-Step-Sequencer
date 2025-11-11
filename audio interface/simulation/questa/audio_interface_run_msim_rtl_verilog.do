transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/UofT/Y2/S1/ece241/final_project/audio\ interface/avconf {D:/UofT/Y2/S1/ece241/final_project/audio interface/avconf/I2C_Controller.v}
vlog -vlog01compat -work work +incdir+D:/UofT/Y2/S1/ece241/final_project/audio\ interface/avconf {D:/UofT/Y2/S1/ece241/final_project/audio interface/avconf/avconf.v}
vlog -vlog01compat -work work +incdir+D:/UofT/Y2/S1/ece241/final_project/audio\ interface {D:/UofT/Y2/S1/ece241/final_project/audio interface/loop_counter.v}
vlog -vlog01compat -work work +incdir+D:/UofT/Y2/S1/ece241/final_project/audio\ interface {D:/UofT/Y2/S1/ece241/final_project/audio interface/audio_interface.v}
vlog -vlog01compat -work work +incdir+D:/UofT/Y2/S1/ece241/final_project/audio\ interface/Audio_Controller {D:/UofT/Y2/S1/ece241/final_project/audio interface/Audio_Controller/Audio_Controller.v}
vlog -vlog01compat -work work +incdir+D:/UofT/Y2/S1/ece241/final_project/audio\ interface/Audio_Controller {D:/UofT/Y2/S1/ece241/final_project/audio interface/Audio_Controller/Audio_Clock.v}
vlog -vlog01compat -work work +incdir+D:/UofT/Y2/S1/ece241/final_project/audio\ interface/Audio_Controller {D:/UofT/Y2/S1/ece241/final_project/audio interface/Audio_Controller/Altera_UP_SYNC_FIFO.v}
vlog -vlog01compat -work work +incdir+D:/UofT/Y2/S1/ece241/final_project/audio\ interface/Audio_Controller {D:/UofT/Y2/S1/ece241/final_project/audio interface/Audio_Controller/Altera_UP_Clock_Edge.v}
vlog -vlog01compat -work work +incdir+D:/UofT/Y2/S1/ece241/final_project/audio\ interface/Audio_Controller {D:/UofT/Y2/S1/ece241/final_project/audio interface/Audio_Controller/Altera_UP_Audio_Out_Serializer.v}
vlog -vlog01compat -work work +incdir+D:/UofT/Y2/S1/ece241/final_project/audio\ interface/Audio_Controller {D:/UofT/Y2/S1/ece241/final_project/audio interface/Audio_Controller/Altera_UP_Audio_In_Deserializer.v}
vlog -vlog01compat -work work +incdir+D:/UofT/Y2/S1/ece241/final_project/audio\ interface/Audio_Controller {D:/UofT/Y2/S1/ece241/final_project/audio interface/Audio_Controller/Altera_UP_Audio_Bit_Counter.v}
vlog -vlog01compat -work work +incdir+D:/UofT/Y2/S1/ece241/final_project/audio\ interface {D:/UofT/Y2/S1/ece241/final_project/audio interface/rom256x16.v}
vlog -vlog01compat -work work +incdir+D:/UofT/Y2/S1/ece241/final_project/audio\ interface {D:/UofT/Y2/S1/ece241/final_project/audio interface/audio_generator.v}
vlog -vlog01compat -work work +incdir+D:/UofT/Y2/S1/ece241/final_project/audio\ interface {D:/UofT/Y2/S1/ece241/final_project/audio interface/BPM_counter.v}
vlog -vlog01compat -work work +incdir+D:/UofT/Y2/S1/ece241/final_project/audio\ interface/db {D:/UofT/Y2/S1/ece241/final_project/audio interface/db/audio_clock_altpll.v}

