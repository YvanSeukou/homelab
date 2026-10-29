# Windows Server : Active Directory, DHCP et déploiement PXE

Une VM Windows Server du lab sert de contrôleur de domaine.

## Rôles installés

- **AD DS** : domaine du lab, utilisateurs, groupes et unités d'organisation.
- **DNS** : intégré à Active Directory.
- **DHCP** : distribue les adresses aux clients du réseau Windows.
- **WDS** (Windows Deployment Services) : installation de postes clients par le réseau (démarrage PXE).

## Points d'attention rencontrés

### Autoriser le serveur DHCP dans Active Directory

Dans un domaine, un serveur DHCP Windows **ne distribue aucune adresse tant qu'il n'est pas autorisé** dans l'Active Directory. Cette protection empêche un serveur DHCP non prévu de perturber le réseau.

```powershell
Add-DhcpServerInDC -DnsName "dc01.lab.local" -IPAddress 10.10.30.10
Get-DhcpServerInDC
```

### PXE avec WDS

- Le client doit être sur le même réseau que le serveur, ou le relais DHCP doit être configuré sur la passerelle.
- Si DHCP et WDS tournent sur le même serveur, il faut indiquer à WDS de ne pas écouter le port 67 et laisser DHCP répondre aux clients PXE.
- Les VM clientes doivent démarrer sur le réseau en premier.

### Stockage sous VirtualBox

Pour les premiers tests sous VirtualBox, j'ai aussi corrigé des problèmes de disques virtuels (contrôleur et disque attachés, ordre de démarrage).

> Les noms de domaine et adresses de ce document sont des exemples.
