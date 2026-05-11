# Manifest ꕤ

Buscador de Manifests.

## Demo

<details>
<summary>Início</summary>

<br>

<img alt="demo-inicio" src="https://github.com/user-attachments/assets/377eaa8f-1514-42ed-9989-56f0eff2038e" />

</details>

<details>
<summary>Config Accela</summary>

<br>

<img alt="demo-config-accela" src="https://github.com/user-attachments/assets/aff309e0-a5b7-41c3-a0fb-1949c4ac26e2" />

</details>

<details>
<summary>ProtonDB</summary>

<br>

<img alt="demo-protondb" src="https://github.com/user-attachments/assets/1942ae45-50c7-4b4b-92a4-8a88fc332466" />

</details>

## Requisitos

- **S.O**: Linux.

- **Dependências**: `bash`, `curl`, `python3`.

## O que faz

- Busca automatizada em 3 endpoints.

- Resolução de nomes para AppID via Steam API.

- Integração com Accela.

- Consulta de compatibilidade Linux via ProtonDB.

- Categorização (Jogo, DLC ou Soundtrack).

### Legenda de cores

<details>
<summary>ProtonDB</summary>

| Status | Badge | Descrição |
| :--- | :--- | :--- |
| **Nativo** | ![Nativo](https://img.shields.io/badge/-Nativo-32CD32?style=flat-square) | Versão oficial desenvolvida para Linux. |
| **Platina** | ![Platina](https://img.shields.io/badge/-Platina-00FFFF?style=flat-square) | Funciona perfeitamente sem necessidade de ajustes. |
| **Ouro** | ![Ouro](https://img.shields.io/badge/-Ouro-FFD700?style=flat-square) | Funciona perfeitamente após ajustes mínimos. |
| **Prata** | ![Prata](https://img.shields.io/badge/-Prata-C0C0C0?style=flat-square) | Funciona, mas apresenta problemas menores. |
| **Bronze** | ![Bronze](https://img.shields.io/badge/-Bronze-CD7F32?style=flat-square) | Jogável, mas com crashes ou bugs frequentes. |
| **Quebrado** | ![Borked](https://img.shields.io/badge/-Borked-FF0000?style=flat-square) | Injogável ou não inicia no Linux. |

</details>

<details>
<summary>SteamDB</summary>

| Tipo | Badge | Descrição |
| :--- | :--- | :--- |
| **Jogo** | ![Jogo](https://img.shields.io/badge/-Jogo-4169E1?style=flat-square) | Título base (Base Game). |
| **DLC** | ![DLC](https://img.shields.io/badge/-DLC-FF00FF?style=flat-square) | Conteúdo adicional para download. |
| **Soundtrack** | ![Soundtrack](https://img.shields.io/badge/-Soundtrack-008000?style=flat-square) | Trilha sonora oficial (Música). |

</details>

## Instalação 

```bash
curl -sSL https://raw.githubusercontent.com/aglairdev/Manifest/main/install.sh | bash
```

## Remoção

```
rm -r ~/.config/Manifest
rm ~/.local/bin/manifest
```

## Créditos

- **Ferramentas:** [DepotDownloaderMod](https://github.com/SteamAutoCracks/DepotDownloaderMod), [SLSsteam](https://github.com/AceSLS/SLSsteam), [SLScheevo](https://github.com/xamionex/SLScheevo), [Steamless](https://github.com/atom0s/Steamless), Accela.

- **Instalador universal:** [enter-the-wired](https://github.com/ciscosweater/enter-the-wired/).

<hr>

> Apenas para fins educacionais.
