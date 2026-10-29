# Retour d'expérience : réseau en virtualisation imbriquée (VMware → Proxmox → OPNsense)

## Contexte

Le lab tourne en virtualisation imbriquée sur un seul PC :

```
PC (Windows)
└── VMware Workstation
    └── VM Proxmox VE (VT-x imbriqué activé)
        ├── vmbr0 : WAN, relié à la carte VMware (NAT)
        ├── vmbr1 : LAN, réseau interne des VM
        ├── VM OPNsense (WAN sur vmbr0, LAN sur vmbr1)
        └── VM clientes (Linux, Windows Server) sur vmbr1
```

**Objectif :** les VM du LAN sortent sur Internet en passant par OPNsense, et OPNsense sort via le réseau de VMware.

## Symptômes

- Les VM du LAN reçoivent bien une adresse et joignent OPNsense, mais **aucun trafic ne sort** au-delà.
- Depuis OPNsense, le WAN obtient parfois une adresse, mais les paquets des VM imbriquées **ne reviennent jamais**.
- Le ping de l'hôte Proxmox lui-même fonctionne : le problème ne touche que les machines « derrière » Proxmox.

## Diagnostic

Trois couches pouvaient bloquer le trafic. Je les ai vérifiées une par une, en partant de la VM et en remontant vers VMware, avec `tcpdump` à chaque saut :

```bash
# Sur Proxmox : les paquets de la VM arrivent-ils sur le bridge LAN ? Repartent-ils côté WAN ?
tcpdump -ni vmbr1 icmp
tcpdump -ni vmbr0 icmp
```

## Causes et corrections

### 1. Mode promiscuous refusé par VMware

Une VM imbriquée a sa propre adresse MAC, différente de celle de la carte virtuelle de Proxmox. Par défaut, l'hyperviseur ne remet à la carte que les trames destinées à **sa** MAC : les réponses destinées aux VM imbriquées sont jetées.

**Correction :** autoriser le mode promiscuous sur la carte réseau de la VM Proxmox côté VMware. Sous Windows, il est autorisé par défaut. Sous un hôte Linux, il faut donner les droits sur `/dev/vmnet*`. Sur ESXi, il faut activer *Promiscuous mode*, *MAC address changes* et *Forged transmits* sur le port group.

### 2. Routage désactivé sur l'hôte Proxmox

Quand l'hôte Proxmox doit faire transiter du trafic entre ses bridges, le noyau doit autoriser le routage.

**Correction :**

```bash
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-ip-forward.conf
sysctl --system
sysctl net.ipv4.ip_forward   # doit afficher 1
```

### 3. Filtrage par OUI du NAT de VMware

C'était le point le plus difficile à trouver. Le service NAT de VMware Workstation (`vmnet8`) ne traite que les trames dont l'adresse MAC appartient aux préfixes VMware (`00:0C:29`, `00:50:56`). Les VM créées par Proxmox ont des MAC en `BC:24:11:…` : le NAT de VMware les ignore sans aucun message d'erreur.

**Corrections possibles :**

- donner à l'interface WAN d'OPNsense une MAC du préfixe VMware (`00:50:56:xx:xx:xx`) dans la configuration de la VM sur Proxmox ;
- ou relier `vmbr0` à un réseau VMware en **mode pont** (bridged) plutôt qu'en NAT ;
- ou faire porter le NAT par Proxmox / OPNsense, pour que seule la MAC de la VM Proxmox sorte vers VMware.

## Résultat

Une fois les trois points corrigés, les VM du LAN sortent sur Internet via OPNsense, et les règles de pare-feu et la segmentation sont gérées dans OPNsense.

## Ce que j'en retiens

- En réseau, je diagnostique **couche par couche** et je vérifie à chaque saut avec `tcpdump`, plutôt que de modifier plusieurs réglages à la fois.
- En virtualisation imbriquée, chaque hyperviseur ajoute ses propres règles de filtrage : il faut les vérifier une par une.
- Je documente la solution, pour pouvoir reconstruire le lab rapidement.
