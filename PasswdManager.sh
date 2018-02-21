#!/bin/bash

# Script for manage users and groups of the system
# created by Emilio Gambone





function opzioni {
	clear
	tput setaf 6
	tput bold
	tput rev
	echo -e "\nGESTIONE UTENTI\n"
	tput sgr0
	echo "1) Stampare tutti gli utenti"
	echo "2) Stampare elenco gruppi"
	echo "3) Stampare gli utenti per gruppo"
	echo "4) inserire nuovo utente"
	echo "5) Modificare utente"
	echo "6) Elimina utente"
	echo "7) Exit"


	echo -e -n "\nInserire la propria scelta: "
	tput bold
	tput sgr0
	read inputUtente

	case $inputUtente in
	1) stampaUtenti ;;
	2) stampaGruppi ;;
	3) utentiXgruppo ;;
	4) inserisciUtente ;;
	5) modificaUtente ;;
	6) eliminaUtente ;;
	7) uscita ;;
	*)  clear
	    echo -e "SCELTA NON VALIDA\n"
	    echo ""
	    read -n 1 -s -p "Press any key to continue" ;;

	esac
}

function stampaUtenti {

	clear

	echo "USERNAME->GROUP"
	echo ""

	cp $passwd passwd_temp.txt                   # creo un file temporaneo di passwd
	cat passwd_temp.txt | wc -l > rows.txt       # creo file con numero righe di passwd
	riga=$(cat rows.txt)			     # inserisco il numero di righe in una variabile
	c=1					     # contatore
	coda=$riga				     # ultima riga
	


	
	while [ $c -le $riga ]	# finche il contatore è minore di riga
	do 
		head -1 passwd_temp.txt | cut -d: -f4 > GID.txt    # creo file con il primo GID
		grep -w $(cat GID.txt) $group | cut -d: -f1 > group_name.txt # creo file con il nome del primo gruppo
		head -1 passwd_temp.txt | cut -d: -f1 > user_name.txt  # creo file con il primo utente

		username=$(head -1 user_name.txt)
		gruppo=$(head -1 group_name.txt)

		echo $username "->" $gruppo

		let coda-=1         # decremento la riga
		cat passwd_temp.txt | tail -$coda > passwd_temp2.txt  # elimino prima riga e salvo su file temporaneo
		cp passwd_temp2.txt passwd_temp.txt 	# copio file temporaneo su passwd_temp.txt
		let c+=1            # incremento contatore
		

	done
	
	#rimozione file temporanei

	rm passwd_temp.txt
	rm rows.txt
	rm GID.txt
	rm group_name.txt
	rm passwd_temp2.txt
	rm user_name.txt
	
	# ritorno al menu
	echo ""
	read -n 1 -s -p "Press any key to continue"
	clear
	
}

function stampaGruppi {
	
	clear

	echo "ELENCO GRUPPI"
	echo ""
	awk -F':' '{ print $1 }' $group    # prendo la colonna dei nomi dei gruppi
	echo ""
	read -n 1 -s -p "Press any key to continue"

	clear
	
}

function utentiXgruppo {  

	clear
	echo "inserire il nome del gruppo da visualizzare:"
	read inputUtente
		
	cp $passwd passwd_temp.txt # copia passwd 
	cut -d: -f1 $group > groups_names.txt # nomi gruppi
	
	if [ $(grep -xc "$inputUtente" groups_names.txt) -eq 0 ] # check esistenza gruppo
	then
		echo ""
		echo "il gruppo inserito non risulta presente"
			
		rm passwd_temp.txt
		rm groups_names.txt

		echo ""
		read -n 1 -s -p "Press any key to continue"
		clear
	else

		grep -xn "$inputUtente" groups_names.txt | cut -d: -f1 > row_number.txt  # riga in cui è presente il gruppo inserito
		
		cut -d: -f1,2 $group > groups_names_gid.txt # nomi,gid dei gruppiprendo la prima parte del file
		head -$(cat row_number.txt) groups_names_gid.txt | tail -1 | cut -d: -f2 > gid.txt; # gid del gruppo inserito

			
		cut -d: -f4 passwd_temp.txt > user_gid.txt; # gid degli utenti
			
			
		grep -xn "$(cat gid.txt)" user_gid.txt | cut -d: -f1 > user_to_print.txt; # righe utenti da stampare
		
		if [ $(grep -c . user_to_print.txt) -eq 0 ] # check se ci sono righe
		then
			echo ""
			echo "Il gruppo inserito non risulta avere nessun utente associato"
			echo ""
			read -n 1 -s -p "Press any key to continue"
			clear
		
		else
			echo ""
			echo "elenco utenti associati:"
			echo ""
				
			coda=$(cat user_to_print.txt | wc -l) # tot righe da stampare
			let coda-=1
				
			while [ $(grep -c . user_to_print.txt) -gt 0 ] # finche il file non è vuoto
			do	
				curr_row=$(cat user_to_print.txt | head -1); #prendo ogni volta la prima riga
				#salvo il nome dell'utente alla riga corrispondente
				print=$(cat passwd_temp.txt | head -$curr_row | tail -1 | cut -d: -f1)
				echo $print	
				cat user_to_print.txt | tail -$coda > temp.txt # tolgo la prima riga
				cp temp.txt user_to_print.txt
				let coda-=1
					
			done
				rm temp.txt
				echo "";
				read -n 1 -s -p "Press any key to continue"	
				
		fi
 		
			#rimuovo i file temporanei
			rm passwd_temp.txt
			rm gid.txt
			rm groups_names.txt
			rm row_number.txt
			rm user_gid.txt
			rm groups_names_gid.txt
			rm user_to_print.txt
		
		fi

	
	
		
	

	
}

function inserisciUtente {

		clear
		echo "INSERIMENTO NUOVO UTENTE"
		echo ""
		echo "inserisci username"
		read nome
		

		cut -d: -f1 $passwd > user_names.txt    # nomi utenti

		if [ $(grep -xc "$nome" user_names.txt) -gt 0 ] # controllo la presenza dell utente che si sta per inserire
		then 
		
			rm user_names.txt

			echo "utente gia presente"
			echo ""
			read -n 1 -s -p "Press any key to continue"
			opzioni
		fi 

	
		while :
		do
			echo "inserire la password:"
			read password
				if [ -z $password ] || [ ${#password} -gt 32 ] 	 # controllo lunghezza password
				then 

					echo "la password inserita non è valida. Deve essere compresa tra 1 e 32 caratteri"
				else 
					break
				fi
			
		done

		echo "inserisci User ID:"
		read uid

		cut -d: -f3 $passwd > uid.txt  # uid gruppi
		if [ $(grep -xc "$uid" uid.txt) -gt 0 ]
		then
			rm user_names.txt
			rm uid.txt
				
			echo "ID gia presente"
			echo ""
			read -n 1 -s -p "Press any key to continue"
			opzioni
		fi
			
		echo "inserisci nome del gruppo:"
		read gruppo

		cut -d: -f1 $group > groups_names.txt # nomi gruppi
		if [ $(grep -xc "$gruppo" groups_names.txt) -eq 0 ]
		then 
			rm user_names.txt
			rm uid.txt
			rm groups_names.txt

			echo "questo gruppo non esiste"
			echo ""
			read -n 1 -s -p "Press any key to continue"
			opzioni
		fi

		echo "inserisci informazioni sull'utente:"
		read infos
		
		echo "inserisci il path della home:"
		read home
		
		echo "inserisci il path della shell:"
		read shell
		
		echo ""
		echo ""
			
			
		grep -xn "$gruppo" groups_names.txt | cut -d: -f1 > curr.txt   # gruppo inserito
			
		head -$(cat curr.txt) $group | tail -1 | cut -d: -f2 > gid.txt 	# gid gruppo
				
		echo $nome:$password:$uid:$(cat gid.txt):$infos:$home:$shell >> $passwd
			
			
		rm user_names.txt
		rm uid.txt
		rm groups_names.txt
		rm gid.txt
		rm curr.txt
		
		echo "l'utente è stato inserito correttamente"
		echo ""
		read -n 1 -s -p "Press any key to continue"
		opzioni
}


function modificaUtente {
		clear
		echo "inserisci nome utente da modificare:"
		read nome
	
		cut -d: -f1 $passwd > users.txt 	# nomi utente
		
		if [ $(grep -wc "$nome" users.txt) -eq 0 ]  # controllo se l'utente esiste
		then
			rm users.txt
			echo ""
			echo "l'utente non esiste"
			
			read -n 1 -s -p "Press any key to continue"
			opzioni
			

		else 
			rm users.txt
			flag=0
			while [ $flag -eq 0 ]
			do
				echo "cosa vuoi modificare?"
				echo "1) password"
				echo "2) gruppo"
				echo "3) informazioni"
				echo "4) path home"
				echo "5) path shell"
				echo "6) exit"
				echo ""
				read inputUtente

				case $inputUtente in
				1) 	flag=1
					modificaPassword ;;
				2)	flag=1
					modificaGruppo ;;
				3)	flag=1
					modificaInfo ;;
				4) 	flag=1
					modificaHome ;;
				5) 	flag=1
					modificaShell ;;
				6) 	flag=1
					opzioni;;
				*) 	clear
					echo -e "SCELTA NON VALIDA\n"
					echo ""
					read -n 1 -s -p "Press any key to continue"
					clear ;;
				esac
			done
		fi

}
	
function modificaPassword {

	while :
	do
		echo "inserire la nuova password:"
		read password_new
		if [ -z $password_new ] || [ ${#password_new} -gt 32 ] 	 # controllo lunghezza password
		then 
			echo "la password inserita non è valida. Deve essere compresa tra 1 e 32 caratteri"
		else 
			break
		fi
			
	done	
	
		
	cat $passwd > passwd_temp.txt 
				
	cat passwd_temp.txt | cut -d: -f1 > usernames.txt  #nomi utente
	grep -xn "$nome" usernames.txt | cut -d: -f1 > row_number.txt #numero riga utente inserito
					
	head -$(cat row_number.txt) passwd_temp.txt | tail -1 > row.txt #riga da modificare
		
	
	echo $nome:$(echo $password_new):$(cut -d: -f3-7 row.txt) > new_row.txt # riga modificata
			
	
	head -$(cat row_number.txt) passwd_temp.txt | tail -1 > riga_da_eliminare.txt # riga da modificare
			
	user_to_delete=$(cut -d: -f1 riga_da_eliminare.txt)
			

	
	sed /"${user_to_delete}"/d passwd_temp.txt > new_file_temp.txt # elimino la riga e salvo in un file temporaneo
	
	cp new_file_temp.txt $passwd; 
		
	cat new_row.txt >> $passwd;
	
	echo "la password è stata modificata con successo"

	echo ""
	read -n 1 -s -p "Press any key to continue"
				
	rm row.txt
	rm new_row.txt
	rm passwd_temp.txt
	rm new_file_temp.txt
	rm row_number.txt
	rm riga_da_eliminare.txt
	rm usernames.txt

		
	

}

function modificaGruppo {  

				echo "inserisci il nome del nuovo gruppo "
				read inputUtente
		
				cut -d: -f1 $group > gruppi.txt 
		
				if [ $(grep -xc "$inputUtente" gruppi.txt) -eq 0 ]
				then
					rm gruppi.txt

					echo "Il gruppo inserito non risulta esistente"
					echo ""
					read -n 1 -s -p "Press any key to continue"
				else
		
					#cat $ cut -d: -f1 > gruppi.txt;
			
					grep -xn "$inputUtente" gruppi.txt | cut -d: -f1 > gruppo_nuovo.txt # nome gruppo da inserire
					
					head -$(cat gruppo_nuovo.txt) $group | tail -1 | cut -d: -f2 > GID.txt # gid gruppo da inserire
 		
					cat $passwd > passwd_temp.txt
					
					cut -d: -f1 passwd_temp.txt > utenti.txt # nomi utenti

					grep -xn "$nome" utenti.txt | cut -d: -f1 > row.txt # 
					
					head -$(cat row.txt) passwd_temp.txt | tail -1 > row_to_del.txt # riga da eliminare
		
					echo $nome:$(cut -d: -f2-3 row_to_del.txt):$(echo $(cat GID.txt)):$(cut -d: -f5-7 row_to_del.txt) > riga_new.txt  # riga da inserire
			
					#elimino l'user vecchio prendendo solo la riga interessata
					head -$(cat gruppo_nuovo.txt) passwd_temp.txt | tail -1 > riga_da_eliminare.txt
					
					grep -w "$nome" riga_da_eliminare.txt | cut -d: -f1-4 > to_del.txt # salvo i primi 4 campi della riga da eliminare
			
					del=$(cat to_del.txt)
	
					sed /"${del}"/d passwd_temp.txt > passwd_temp2.txt
	
					cp passwd_temp2.txt $passwd
		
					cat riga_new.txt >> $passwd
					echo ""
					read -n 1 -s -p "Press any key to continue"
							
		
					rm gruppi.txt
					rm GID.txt
					rm passwd_temp.txt
					rm passwd_temp2.txt
					rm riga_new.txt
					rm riga_da_eliminare.txt
					rm row_to_del.txt
					rm gruppo_nuovo.txt
					rm utenti.txt
					rm to_del.txt
					rm row.txt
					

				fi


}		

function modificaInfo {

echo "inserisci la nuova informazione utente:"	
				read infos
		
				cat $passwd > passwd_temp.txt
				cut -d: -f1 passwd_temp.txt > users.txt # nomi utente
				row_number=$(grep -xn "$nome" users.txt | cut -d: -f1)
				head -$row_number passwd_temp.txt | tail -1 > riga_da_modificare.txt

				#modifico l'utente desiderato con la nuova password
				echo $nome:$(cut -d: -f2-4 riga_da_modificare.txt):$(echo $infos):$(cut -d: -f6-7 riga_da_modificare.txt) > nuova_riga.txt
			
				#elimino l'user vecchio prendendo solo la riga interessata
				head -$row_number passwd_temp.txt | tail -1 > UserKey.txt
			
				grep -w "$nome" UserKey.txt | cut -d: -f1-4 > delete.txt # da eliminare 
			
				to_del=$(cat delete.txt)
	
				sed /"${to_del}"/d passwd_temp.txt > NewPasswdTemp.txt
	
				cp NewPasswdTemp.txt $passwd
		
				cat nuova_riga.txt >> $passwd

			
				#rimuovo i file temporanei
				rm passwd_temp.txt
				rm riga_da_modificare.txt
				rm nuova_riga.txt
				rm NewPasswdTemp.txt
				rm delete.txt
				rm UserKey.txt
				rm users.txt
}

function modificaHome {

echo "inserisci la nuova path della home per $nome :"	
				read home
		
				cat $passwd > passwd_temp.txt
				cut -d: -f1 passwd_temp.txt > users.txt # nomi utente
				row_number=$(grep -xn "$nome" users.txt | cut -d: -f1)
				head -$row_number passwd_temp.txt | tail -1 > riga_da_modificare.txt

				echo $nome:$(cut -d: -f2-5 riga_da_modificare.txt):$(echo $home):$(cut -d: -f7 riga_da_modificare.txt) > nuova_riga.txt
			

				head -$row_number passwd_temp.txt | tail -1 > UserKey.txt
			
				grep -w "$nome" UserKey.txt | cut -d: -f1-4 > delete.txt # da eliminare 
			
				to_del=$(cat delete.txt)
	
				sed /"${to_del}"/d passwd_temp.txt > NewPasswdTemp.txt
	
				cp NewPasswdTemp.txt $passwd
		
				cat nuova_riga.txt >> $passwd

			
				#rimuovo i file temporanei
				rm passwd_temp.txt
				rm riga_da_modificare.txt
				rm nuova_riga.txt
				rm NewPasswdTemp.txt
				rm delete.txt
				rm UserKey.txt
				rm users.txt
}

function modificaShell {

echo "inserisci la nuova path per la shell di $nome:"	
				read shell
		
				cat $passwd > passwd_temp.txt
				cut -d: -f1 passwd_temp.txt > users.txt # nomi utente
				row_number=$(grep -xn "$nome" users.txt | cut -d: -f1)
				head -$row_number passwd_temp.txt | tail -1 > riga_da_modificare.txt

				#modifico l'utente desiderato con la nuova password
				echo $nome:$(cut -d: -f2-6 riga_da_modificare.txt):$(echo $shell)> nuova_riga.txt
			
				#elimino l'user vecchio prendendo solo la riga interessata
				head -$row_number passwd_temp.txt | tail -1 > UserKey.txt
			
				grep -w "$nome" UserKey.txt | cut -d: -f1-4 > delete.txt # da eliminare 
			
				to_del=$(cat delete.txt)
	
				sed /"${to_del}"/d passwd_temp.txt > NewPasswdTemp.txt
	
				cp NewPasswdTemp.txt $passwd
		
				cat nuova_riga.txt >> $passwd

			
				#rimuovo i file temporanei
				rm passwd_temp.txt
				rm riga_da_modificare.txt
				rm nuova_riga.txt
				rm NewPasswdTemp.txt
				rm delete.txt
				rm UserKey.txt
				rm users.txt
}

function eliminaUtente {

		echo ""
		echo "Inserisci il nome dell'utente da eliminare da passwd:"
		read inputUtente
	
		
		cat $passwd > passwd_temp.txt
		if [ $(grep -wc "$inputUtente" passwd_temp.txt) -eq 0 ]
		then
			clear
			echo "L'utente non risulta presente"
			echo ""
			read -n 1 -s -p "Press any key to continue"
			rm passwd_temp.txt
			opzioni
	
		else
		
			cut -d: -f1 passwd_temp.txt > usernames.txt
			grep -xn "$inputUtente" usernames.txt | cut -d: -f1 > row_number.txt
			head -$(cat row_number.txt) passwd_temp.txt | tail -1 > row_to_del.txt
		
			del=$(cat row_to_del.txt)
	
			sed /"${del}"/d passwd_temp.txt > NewPasswdTemp.txt
	
			cp NewPasswdTemp.txt $passwd
			
			#cat $1;
	
			#rimuovo i file temporanei
			rm passwd_temp.txt
			rm NewPasswdTemp.txt
			rm row_to_del.txt
			rm usrnames.txt
			rm row_number.txt
	
		fi
}

function uscita {
	
	clear
	notify-send  "Uscita dal programma.."
	exit 0

}

#MAIN

if test $# -gt 2 
	then 
		echo "ERROR"
		echo "too many arguments"
		echo "usage : PATTERN[passwd] PATTERN[group]"
		echo "ATTENTION: passare prima il percorso di passwd e poi quello di group"
		exit 0
	else
		if test $# -lt 2
		then
			echo "ERROR"
			echo "argument missing"
			echo "usage : PATTERN[passwd] PATTERN[group]"
			echo "ATTENTION: passare prima il percorso di passwd e poi quello di group"
			exit 0
		else 	
			if [ ! -f "$1" ]
			then
				echo "ERRORE"
				echo "il file passwd inserito non esiste"
				exit 0	
			fi
	

			if [ ! -f "$2" ]
			then
				echo "ERRORE"
				echo "il file group inserito non esiste"
				exit 0	
			fi
		fi

	fi
	
	passwd=$1
	group=$2
	
	

	while :;
	do
		opzioni	
	done

