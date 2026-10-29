# Retour d'expérience : déployer ChartDB sur un petit serveur Linux

[ChartDB](https://github.com/chartdb/chartdb) est un outil open source qui affiche le schéma d'une base de données (MySQL, PostgreSQL…) sous forme de diagramme. Je l'ai auto-hébergé (v1.7.0) sur une VM Linux du lab.

## Problèmes rencontrés

### 1. Version de Node.js incompatible

La compilation échouait avec la version de Node.js installée par défaut sur la distribution.

**Correction :** installer la version de Node.js demandée par le projet (champ `engines` du `package.json`), par exemple avec `nvm`, ou compiler directement dans l'image Docker fournie, qui embarque la bonne version.

### 2. Build Vite tué par manque de mémoire (SIGKILL)

Pendant `docker build`, l'étape de compilation Vite s'arrêtait brutalement avec un `SIGKILL` : le noyau tuait le processus faute de RAM (OOM killer).

**Diagnostic :**

```bash
dmesg | grep -i -E "killed process|out of memory"
free -h
```

### 3. Pas de swap sur la VM

La VM n'avait pas de swap pour absorber le pic de mémoire du build.

**Correction :** créer un fichier d'échange.

```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

Si `fallocate` n'est pas supporté par le système de fichiers, utiliser `dd if=/dev/zero of=/swapfile bs=1M count=4096`.

## Résultat

Le build passe, et ChartDB tourne dans un conteneur Docker sur la VM.

## Ce que j'en retiens

- Un `SIGKILL` sans message d'erreur pendant un build signale très souvent un manque de mémoire : il faut regarder `dmesg` avant de chercher ailleurs.
- Compiler sur une grosse machine, puis ne déployer que l'image finale (build multi-étapes ou registre), évite de surdimensionner les petits serveurs.
