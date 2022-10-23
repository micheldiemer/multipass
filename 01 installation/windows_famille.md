# Multipass VirtualBox Windows Famille

## Solution 1 - Recommandée

**Acheter une licence Windows Pro**

## Solution 2 - Fortement déconseillée

1. Télécharger et installer VirtualBox
2. Activer Hyper-V dans Windows (Panneau de Configuration / Programmes / fonctionnalités facultatives)
3. Télécharger et extraire PSTools
4. Ajouter le dossier de virtualBox contenant VBoxManage.exe dans PATH
5. Ajouter le dossier de PSTools dans le PATH
6. Télécharger Multipass
7. Installer multipass
8. Vérifier le nom du réseau dans Powershell `Get-NetAdapter -Physical | format-list -property "Name","DriverDescription"`
9. Lancer une machine virtuelle avec multipass
10. voir le fichier html pour la gestion des gestion des réseaux
