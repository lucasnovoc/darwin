*** Prueba de humo: barrido DC de un NMOS de IHP 130 nm ***

.lib cornerMOSlv.lib mos_tt

Vdd D1 0 dc=1.2
Vgs G1 0 dc=0.5

Xn1 D1 G1 0 0 sg13_lv_nmos w=2u l=1u m=1

.control
dc Vgs 0 1.2 0.1
let id = -i(Vdd)
print v(G1) id
meas dc id_max max id
.endc

.end
