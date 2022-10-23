#!/bin/bash

# ------------------------------------------------------------------
# Adresse IP par défaut pour les machines stoppées
# ------------------------------------------------------------------
DEFAULT_STOPPED=127.0.0.1
# Autres valeurs possibles
#     ip          n'importe quelle adresse IP
#     delete      supprime les lignes
#     comment     comment les lignes

#
# Multipass Update Hosts
# Met à jour le fichiers hosts d'après les adresses IP des VM multipass
#     - Lance la commande `multipass list` et récupère les lignes
#       (voir la commande $LIST)
#     - Récupère les noms des machines
#     - Pour chaque ligne
#            - récupère le nom de la machine et l'adresse IP
#            - si le commentaire #multipass-machine est trouvé dans $MHOSTS
#                 (voir la commande $LIST_HOSTS)
#                 mettre à jour l'adresse IP
#                    soit avec la nouvelle adresse IP
#                    soit mettre une adresse IP par défaut       DEFAULT_STOPPED=<valeur>
#                    soit commenter la ligne (machine éteinte)   DEFAULT_STOPPED=comment
#                    soit supprimer la ligne (machine supprimée) DEFAULT_STOPPED=delete
#            - sinon
#                 si la machine est démarrée
#                    ajouter une ligne avec le nom de la machine et un commentaire
#                 finsi
#            - finsi
#     - FinPour
#
#     Copier le fichiers $MHOSTS vers $TMPHOSTS
#     Créer la commande sed en ajoutant autant de -e qu'il faut
#     Rediriger la sortie du fichier $MHOSTS vers $TMPHOSTS
#     Demander la confirmation à l'utilisateur
#        Si Oui, Remplacer $MHOSTS par $TMPHOSTS
#



# ------------------------------------------------------------------
# Test : la variables HOSTS doit contenir le fichier hosts
# ---------------------------------------------------------------------
if [ ! -f "$MHOSTS" ];
then
  echo "J'ai besoin que HOSTS soit le fichier hosts"
  if [ -f "/c/Windows/System32/drivers/etc/hosts" ];
  then
    echo "   export MHOSTS=/c/Windows/System32/drivers/etc/hosts"

  else
    if [ -f "/etc/hosts" ];
    then
      echo "   export MHOSTS=/etc/hosts"
    fi
  fi
  exit 1;
fi

# ---------------------------------------------------------------------
# Vérifier que multipass.exe est dans le PATH
# par exemple
#     export PATH=$PATH:"/c/Program Files/Multipass/bin"
# ---------------------------------------------------------------------
command -v multipass >/dev/null 2>&1 || {
  echo 'multipass non trouvé. Essayez '
  echo '   export PATH=$PATH:"/c/Program Files/Multipass/bin"' >&2 "";
  exit 2;
}

# ---------------------------------------------------------------------
# Liste des machines démarrées
# ---------------------------------------------------------------------
LIST=$(multipass list | grep  -v "^Name.*State" )
# DEBUG
# echo  "${LIST}" && exit

# ---------------------------------------------------------------------
# On met la liste dans un tableau
# ---------------------------------------------------------------------
IFS=$'\n' read -d '' -r -a tableau_machines < <(echo "${LIST}")
# DEBUG
#for element in "${my_array[@]}"; do echo $element ${#element}; done && exit
#echo "${my_array[0]}" | tr -s ' ' | cut -d " " -f 1,3

if [ "${#tableau_machines[@]}" -eq "0" ]
then
  echo "Erreur : multipass list ne trouve aucune machine"
  exit 3
fi

# ---------------------------------------------------------------------
# Parcours du tableau
# ---------------------------------------------------------------------

# Liste des commandes à exécuter pour mettre à jour le fichier hosts
sed_exprs=()

for machine in "${tableau_machines[@]}"
do
  # Pas de données => machine suivante
	if [[ ! $machine ]]; then continue; fi
	#echo $machine ${#machine}

  # $machine est une ligne complète renvoyée par Multipass
  # récupération du nom de la machine
	IFS=' ' read -r -a donnees_machine <<< "$machine"
  nom_machine=${donnees_machine[0]}
  ip_machine=${donnees_machine[2]}

  # Vérification que l'adresse ip est bien une adresse ip
  if [[ ! $ip_machine =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]];
  then
    ip_machine=$DEFAULT_STOPPED
    running=0
  else
    running=1
  fi

  # recherche de toutes les lignes du fichier hosts
  #   contenant le nom de la machine
  #   via la commande grep
  #
  #       grep $comment        on cherche #multipass-machine
  #       grep -v "^# "        on supprime les lignes qui commencent par commentaire espace
  #       grep -v "^#[a-zA-Z]" on supprime les ligens qui commencent par commentaire lettre
  #       on garde les lignes qui commencent par commentaire chiffre
  #       pour les machines éteintes les adresses IP peuvent être ne commentaire
  #
  comment="#multipass-${nom_machine}"
  LIST_HOSTS=$(grep $comment $MHOSTS | grep -v "^# " | grep -v "^#[a-zA-Z]")
  IFS=$'\n' read -d '' -r -a hostnames < <(echo "${LIST_HOSTS}")

  # Récupération de l'adresse IP actuelle dans le fichier hosts
  OLD_IP_IN_HOSTS=X
  if [ "${#hostnames[@]}" -gt "0" ]; then

    # On a trouvé au moins une machine avec le commantaire
    # Récupération de l'ancienne adresse IP
    #   en vérifiant que le format de l'adresse IP est correct
    #   une adresse IP a le droit de commencer par un commentaire
    i=0
    while [[ ! $OLD_IP_IN_HOSTS =~ ^[\#]*[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
    do
      if [ $i -ge ${#hostnames[@]} ]; then break; fi
      hostname=${hostnames[$i]}
      IFS=' ' read -r -a donnees_hosts <<< "$hostname"
      OLD_IP_IN_HOSTS=${donnees_hosts[0]}
      i=$((i+1))
      echo $i $OLD_IP_IN_HOSTS
    done
  fi


  if [[ $OLD_IP_IN_HOSTS =~ ^[\#]*[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    # on a trouvé une adresse IP dans le fichiers hosts
    if [ "$OLD_IP_IN_HOSTS" == "$ip_machine" ]; then
      :
      # les deux adressees IP sont identiques, ne rien faire
    else if [ "$ip_machine" == "comment" ]; then
      # mettre en commentaire les entrées correspondant aux machines arrêtées
      echo $comment OLD_IP=$OLD_IP_IN_HOSTS commentaire
      sed_expr="s/[\#]*$OLD_IP_IN_HOSTS/#$OLD_IP_IN_HOSTS/g"
      sed_exprs[${#sed_exprs[@]}]=$sed_expr
      echo "sed -i -e \"${sed_expr}\" \$MHOSTS"
    else if [ "$ip_machine" == "delete" ]; then
      # supprimer les entrées correspondant aux machines arrêtées
      echo $comment OLD_IP=$OLD_IP_IN_HOSTS suppression
      sed_expr="  /$comment/d"
      sed_exprs[${#sed_exprs[@]}]=$sed_expr
      echo "sed -i -e \"${sed_expr}\" \$MHOSTS"
      continue;
    else
      # mettre à jour les adresses IP
      echo $comment OLD_IP=$OLD_IP_IN_HOSTS NEW_IP=$ip_machine
      sed_expr="s/[\#]*$OLD_IP_IN_HOSTS/$ip_machine/g"
      sed_exprs[${#sed_exprs[@]}]=$sed_expr
      echo "sed -i -e \"${sed_expr}\" \$MHOSTS"
    fi fi fi
  else if [ $running -eq 1 ]; then
    # La machine multipass n'existe pas dans le fichier hosts
    #    et elle est démarrée
    # Affichage de l'information
    # Possibilité d'ajouter la machine dans le fichier hosts
    #   sed $ a\texte           ajoute texte à la fin du fichier
    echo $comment
    sed_expr="$ a\\$ip_machine $nom_machine.local $comment"
    sed_exprs[${#sed_exprs[@]}]=$sed_expr
    echo "sed -i -e \"${sed_expr}\" \$MHOSTS"
    sed_expr="$ a\\$ip_machine www.$nom_machine.local $comment"
    sed_exprs[${#sed_exprs[@]}]=$sed_expr
    echo "sed -i -e \"${sed_expr}\" \$MHOSTS"
  fi fi
done

# Est-ce qu'il y a quelque chose à modifier ?
if [ "${#sed_exprs[@]}" -eq "0" ]; then
  echo "# Aucun changement dans le fichiers hosts"
  echo "# Les adresses IP n'ont pas changé"
  echo "# Aucune nouvelle machine n'est démarrée"
  exit 10
fi

# ---------------------------------------------------------------------
# Création d'une seule commande sed
#     sed -i fonctionne mal
#         => utilisation d'un fichier temporaire
# ---------------------------------------------------------------------
sed_command="sed "
for sed_expr in "${sed_exprs[@]}"
do
  sed_command="${sed_command} -e \"${sed_expr}\""
done

# Modifier le fichiers $MHOSTS
TMPHOSTS=/tmp/hosts
echo "Création du nouveau fichiers hosts dans le dossier local"
sed_command="${sed_command} $MHOSTS >  $TMPHOSTS"
eval $sed_command
echo "---------------------------------------------------------------------"
echo "Contenu du fichier hosts actuel"
echo "---------------------------------------------------------------------"
cat $MHOSTS

echo "---------------------------------------------------------------------"
echo "Contenu du nouveau fichier hosts"
echo "---------------------------------------------------------------------"
cat  $TMPHOSTS

echo "---------------------------------------------------------------------"
echo "Différences"
echo "---------------------------------------------------------------------"
diff $MHOSTS $TMPHOSTS


# ---------------------------------------------------------------------
# Demande de confirmation à l'utilisateur
# ---------------------------------------------------------------------
echo
echo
echo "Mettre à your le fichier hosts ? "
select yn in "Oui" "Non"; do
    case $yn in
        Oui )
          mv $TMPHOSTS $MHOSTS
          break;;
        Non )
          exit;;
    esac
done
