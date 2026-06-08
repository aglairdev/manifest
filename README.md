# Manifest ꕤ

Buscador de Manifests.

## Demo

<details>
<summary>Início</summary>

<br>

<img alt="demo-inicio" src="https://github.com/user-attachments/assets/0df02197-5624-4478-9d0e-955d04a2e794" />

</details>

<details>
<summary>Config Accela</summary>

<br>

<img alt="demo-config-accela" src="https://github.com/user-attachments/assets/2aa8df08-cadb-4da4-b686-fc16a7a24c2e" />

</details>

<details>
<summary>ProtonDB</summary>

<br>

<img alt="demo-protondb" src="https://github.com/user-attachments/assets/9abe2bd4-5693-4a69-a2d3-724cb2757311" />

</details>

## Requisitos

- **S.O**: Linux.

- **Dependências**: `bash`, `curl`, `python3`.

## O que faz

- Busca automatizada em 3 endpoints.

- Resolução de nomes para AppID via Steam API.

- Integração com Accela [`20260425230142`].

- Consulta de compatibilidade Linux via ProtonDB.

- Categorização (Jogo, DLC ou Soundtrack).

- Integração com SLScheevo.

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
