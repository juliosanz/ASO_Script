#!/bin/bash

ProgramarPracticas () 
{
	echo "Asignatura cuyas prácticas desea recoger:"
	read asignatura	
	echo "Ruta absoluta con las cuentas de los alumnos:"
	valid_path=false
	while [ $valid_path = false ]
	do
		read path_alumnos
		echo $path_alumnos
	 	if [[ ! -d $path_alumnos ]]
		then
			echo "Este directorio ($path_alumnos) no existe. Introduce uno válido." | tee -a informe-prac.log
		else
			valid_path=true
		fi
	done
	echo "Ruta absoluta para almacenar las practicas:"
	read path_practicas
	if [[ ! -d $path_practicas ]]
	then
		mkdir $path_practicas
	fi
	echo "Se va a programar la recogida de las prácticas de ASO para mañana a las 8:00. Origen: $path_alumnos. Destino: $path_practicas.";
	echo "¿Está de acuerdo? (s/n)"
	read acuerdo
	if [ $acuerdo = "s" ]
	then
		day=$(($(date +%d) + 1))
		month=$(date +%m)
		echo "0 8 $day $month * recoge-prac.sh $path_alumnos $path_practicas" >crontab-schedule 
		crontab crontab-schedule 
	fi
}

EmpaquetarPracticas ()
{
	echo "Asignatura cuyas prácticas se desea empaquetar:"
	#read asignatura
	asignatura="ASO"
	echo "Ruta absoluta del directorio de prácticas:"
	valid_path=false
	while [ $valid_path = false ]
	do
		#read path_alumnos
		path_alumnos="/home/julio/aso/destino"
		echo $path_alumnos
	 	if [[ ! -d $path_alumnos ]]
		then
			echo "Este directorio de prácticas ($path_alumnos) no existe. Introduce uno válido." | tee -a informe-prac.log
		else
			valid_path=true
		fi
	done
	echo "Se van a empaquetar las prácticas de la asignatura ASO presentes en el directorio $path_alumnos."
	echo "¿Está de acuerdo? (s/n)"
	read acuerdo
	if [ $acuerdo = "s" ]
	then
		tarname=$asignatura-$(date +%y%m%d-%H%M)
		tar -C $path_alumnos -cvzf $path_alumnos/$tarname.tgz $path_alumnos/
		path_dict["$asignatura"]=$path_alumnos
		python3 persistencia.py $asignatura $path_alumnos 
	fi
}

InfoPaquete ()
{
	echo "Asignatura sobre la que se quiere información:"
	read asignatura
	dir=${path_dict["$asignatura"]}
	file=$(ls $dir | grep "^$asignatura")
	size=$(stat -c%s "$dir/$file")
	echo "El fichero comprimido se llama $file, y pesa $size."
}

in_script=true;
declare -A path_dict
if [ $1 = -p ]
then
	echo "------Modo persistente------"
	echo "La ubicación de todos los paquetes de prácticas que crees será almacenada."
	if [[ ! -f $(pwd)/paths.json ]]
	then
		echo "{" >paths.json	
		echo "	\"ignore\":\"this\"" >>paths.json
		echo "}" >>paths.json
	fi
fi
while [ $in_script = true ]
do
	echo "Gestión de prácticas"
	echo "--------------------"
	echo ""
	echo "1) Programar Prácticas"
	echo "2) Empaquetar prácticas"
	echo "3) Ver información de paquetes"
	echo "4) Salir"
	read option
	case "$option" in
		1)
		 ProgramarPracticas
		 ;;
		2)
		 EmpaquetarPracticas
		 for key in "${!path_dict[@]}"
		 do
		 	echo "$key"
			echo "${path_dict[$key]}"
		 done
		 ;;
		3)
		 InfoPaquete
		 ;;
		4)
		 in_script=false
		 ;;
	esac
done
