# 🎮 2D Multiplayer Co-Op Game

Um jogo 2D coop/multiplayer desenvolvido utilizando a **Godot Engine 4.4.1**. Este projeto implementa uma arquitetura multiplayer de alto nível nativa da Godot, com suporte para hospedagem de partidas (Host), entrada de jogadores (Join), sincronização de movimentação e estados em tempo real.

## 📌 Sumário

* [Sobre o Projeto](#-sobre-o-projeto)

* [Recursos Principais](#-recursos-principais)

* [Pré-requisitos](#-pré-requisitos)

* [Como Executar o Projeto](#-como-executar-o-projeto)

* [Como Testar Multiplayer Localmente](#-como-testar-multiplayer-localmente)

* [Arquitetura de Rede (Godot 4.4)](#-arquitetura-de-rede-godot-44)

* [Estrutura de Pastas Sugerida](#-estrutura-de-pastas-sugerida)

* [Licença](#-licença)

## 🌐 Sobre o Projeto

Este repositório é um projeto de jogo 2D cooperativo focado na criação de uma experiência fluida de multijogador em tempo real. Ele aproveita os recursos modernos do ecossistema **Godot 4.x** (como `MultiplayerSpawner`, `MultiplayerSynchronizer` e `ENetMultiplayerPeer`) para oferecer sincronização leve e eficiente de estados e objetos entre servidor e clientes.

## ✨ Recursos Principais

* 🔌 **Lobby & Conexão (Host / Join)**: Interface para criar salas localmente ou se conectar via endereço IP/porta.

* 🔄 **Sincronização de Posição e Estados**: Uso de `MultiplayerSynchronizer` para interpolação e sincronização suave dos personagens.

* 👾 **Instanciação Dinâmica**: Spawners automáticos com `MultiplayerSpawner` para novos jogadores e entidades no mundo.

* 🕹️ **Modo Cooperativo 2D**: Suporte a controle de múltiplos jogadores simultâneos no mesmo mapa.

* 📡 **Chamadas RPC**: Estrutura organizada para envio de eventos confiáveis (`reliable`) e não-confiáveis (`unreliable`) via servidor.

## 🛠️ Pré-requisitos

Para rodar e editar o projeto, você precisará de:

* [Godot Engine v4.4.1](https://godotengine.org/download?utm_source=gemini) (ou versão superior do ramo 4.4).

* [Git](https://git-scm.com/?utm_source=gemini) instalado em sua máquina.

## 🚀 Como Executar o Projeto

1. **Clone o repositório:**

   ```
   git clone https://github.com/VictorPrazeres/2DMultiplayer.git
   cd 2DMultiplayer
   
   ```

2. **Abra o projeto na Godot Engine:**

   * Abra a **Godot 4.4.1**.

   * Clique no botão **Importar** (Import).

   * Selecione o arquivo `project.godot` dentro da pasta clonada.

   * Clique em **Importar e Editar**.

3. **Inicie o jogo:**

   * Pressione `F5` no editor de texto/cenas para rodar a cena principal.

## 🧪 Como Testar Multiplayer Localmente

A Godot permite rodar múltiplas instâncias do jogo diretamente pelo editor para testar conexões locais:

1. No canto superior direito do editor da Godot, clique na aba **Debug**.

2. Altere a opção **Run Multiple Instances** (Executar Múltiplas Instâncias) de `1` para `2` (ou mais).

3. Pressione `F5` para iniciar. Duas janelas do jogo abrirão simultaneamente:

   * Na **Janela 1**: Clique em **Host** para criar a sala local (porta padrão `8910` ou similar).

   * Na **Janela 2**: Certifique-se de que o IP está definido como `127.0.0.1` e clique em **Join**.

## 📡 Arquitetura de Rede (Godot 4.4)

O projeto faz uso das seguintes APIs nativas da Godot 4:

* **`ENetMultiplayerPeer`**: Responsável por estabelecer a conexão via protocolo UDP de baixa latência.

* **`MultiplayerSpawner`**: Sincroniza a criação e destruição de nós (como os players) entre todos os clientes automaticamente.

* **`MultiplayerSynchronizer`**: Sincroniza variáveis específicas em tempo real (posição, velocidade, animação ativa) sem requerer código RPC repetitivo.

* **`Anotações @rpc`**:

  * `@rpc("any_peer", "call_local", "reliable")`: Utilizado em ações pontuais cruciais (interações, ataques, reinício).

  * `@rpc("authority", "unreliable")`: Utilizado para dados frequentes de física ou interpolação.

## 📁 Estrutura do Projeto

```
2DMultiplayer/
├── assets/
├── autoload/
├── component/
├── effect/
│   ├── muzzle_flash/
├── entities/
│   ├── enemy/
│   └── player/
├── game_object/
│   ├── bullet/
├── manager/
├── resources/
│   ├── font/
│   ├── shader/
│   └── theme.tres
├── ui/
│   ├── game_ui/
│   └── main_menu/
├── project.godot    # Arquivo de configuração do projeto
└── README.md
```

## 📜 Licença

Este projeto está licenciado sob a Licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

Desenvolvido por [**Victor Prazeres**](https://github.com/VictorPrazeres?utm_source=gemini).
