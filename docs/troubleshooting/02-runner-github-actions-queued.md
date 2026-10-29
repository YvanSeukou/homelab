# Retour d'expérience : jobs GitHub Actions bloqués en « Queued »

## Symptôme

Tous les jobs d'un workflow restaient indéfiniment au statut **Queued**, sans démarrer ni échouer.

## Cause

Le workflow ciblait un **runner auto-hébergé** (`runs-on: self-hosted`) installé sur une VM du lab, et ce runner était **hors ligne**. GitHub ne bascule pas vers un runner hébergé : il attend qu'un runner portant les bons labels se connecte.

## Diagnostic

1. Dans le dépôt, **Settings → Actions → Runners** : le runner apparaissait *Offline*.
2. Sur la VM, vérifier le service du runner :

```bash
cd ~/actions-runner
sudo ./svc.sh status
```

3. Vérifier que la VM sort bien sur Internet (le runner a besoin d'une connexion HTTPS sortante vers GitHub) : DNS, passerelle OPNsense, règles du pare-feu.

## Correction

```bash
sudo ./svc.sh start
```

Pour que le runner redémarre avec la VM, il doit être installé comme service (`sudo ./svc.sh install`) et non lancé à la main avec `./run.sh`.

## Ce que j'en retiens

- « Queued » sans erreur sur un runner auto-hébergé veut presque toujours dire « aucun runner disponible avec ces labels ».
- Un runner auto-hébergé est une machine à superviser comme les autres : service au démarrage, accès réseau sortant, espace disque.
