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
	if [[ $acuerdo = "s" ]]
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
	read asignatura
	echo "Ruta absoluta del directorio de prácticas:"
	valid_path=false
	while [ $valid_path = false ]
	do
		read path_alumnos
		echo $path_alumnos
	 	if [[ ! -d $path_alumnos ]]
		then
			echo "Este directorio de prácticas ($path_alumnos) no existe. Introduce uno válido." | tee -a informe-prac.log
		else
			valid_path=true
		fi
	done
	echo "Se van a empaquetar las prácticas de la asignatura $asignatura presentes en el directorio $path_alumnos."
	echo "¿Está de acuerdo? (s/n)"
	read acuerdo
	if [[ $acuerdo == "s" ]]
	then
		stat -c%n $path_alumnos/$asignatura*
		if [[ $? == 0 ]]
		then
			echo "Ya existen uno o varios comprimidos anteriores con las prácticas de esta asignatura en este directorio. ¿Deseas sobrescribirlo/s? (s/n)"
			read acuerdo2
			if [[ $acuerdo2 == "s" ]]
			then
				rm $path_alumnos/$asignatura*
			fi
		fi
		tarname=$asignatura-$(date +%y%m%d-%H%M)
		tar -C $path_alumnos -cvzf $path_alumnos/$tarname.tgz $path_alumnos/*.sh
		path_dict["$asignatura"]=$path_alumnos
		if [[ $1 == "-p" ]]
		then
			echo "$asignatura:$path_alumnos" >>path
		fi
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

in_script=true
declare -A path_dict
if [[ $1 == "-p" ]]
then
	echo "------Modo persistente------"
	echo "La ubicación de todos los paquetes de prácticas que crees será almacenada."
	touch path
	while read line   
	do
		key=$(echo $line | cut -d ":" -f 1)
		value=$(echo $line | cut -d ":" -f 2)
		path_dict["$key"]=$value	
	done <path
	echo "Asignaturas actuales guardadas:"
	for key in "${!path_dict[@]}"
	do
	 	echo "$key"
		echo "${path_dict[$key]}"
	done
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
		 EmpaquetarPracticas $1
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
