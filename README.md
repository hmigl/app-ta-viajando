# ✈️ Tá Viajando, é?

**Tá Viajando, é?** é um aplicativo móvel e web desenvolvido em Flutter para planejamento colaborativo de viagens. O app permite criar roteiros, convidar amigos, gerenciar tarefas (checklist), definir destinos com geolocalização e personalizar o perfil do viajante.

![Status do Projeto](https://img.shields.io/badge/Status-Em_Desenvolvimento-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)

## 📋 Funcionalidades

* **Autenticação Robusta:** Login via E-mail/Senha e Google OAuth.
* **Gestão de Viagens:** CRUD completo de viagens com atualização em tempo real.
* **Colaboração:** Convite de participantes via e-mail e identificação de organizadores.
* **Checklist de Tarefas:** Controle de itens para levar, sincronizado entre todos os participantes.
* **Geolocalização:**
    * Conversão de endereço para coordenadas (Geocoding via OpenStreetMap).
    * Visualização de mapas interativos (`flutter_map`).
* **Mídia e Storage:** Upload de capas para viagens e fotos de perfil.
* **Social:** Visualização de perfil e lista de amigos (conexões de viagem).
* **Temas:** Suporte completo a **Dark Mode** e Light Mode.

## 📂 Estrutura do Projeto

O projeto segue uma arquitetura baseada em *Features* (Funcionalidades) com *Riverpod*:

```text
lib/
├── core/                       # Núcleo da aplicação
│   └── services/
│       ├── auth_provider.dart  # Lógica de Autenticação
│       ├── geocoding_service.dart # API de Mapas
│       ├── supabase_provider.dart # Cliente Supabase
│       ├── theme_provider.dart # Controle de Tema
│       └── supabase_options.dart # (⚠️ Criar Manualmente)
│
├── features/                   # Módulos funcionais
│   ├── auth/                   # Login, Registro e Repositório de Perfil
│   ├── global/                 # Menu Lateral, Tela de Perfil e Amigos
│   ├── home/                   # Tela inicial
│   └── trips/                  # Módulo de Viagens
│       ├── data/               # Repositórios e conexão com DB
│       ├── domain/             # Modelos (Trip, Task, Participant)
│       ├── presentation/       # Controllers e Modais
│       └── screens/            # Telas de Detalhes e Listagem
│
├── main.dart                   # Inicialização
└── my_app.dart                 # Rotas e Temas
```


## 🚀 Como Rodar o Projeto

Siga **rigorosamente** os passos abaixo para configurar corretamente o ambiente de desenvolvimento.



### 📦 1. Clonar o Repositório e Instalar Dependências

No terminal, execute:

```bash
git clone https://github.com/SEU_USUARIO/ta_viajando_app.git
cd ta_viajando_app
flutter pub get
```

---

### 🔐 2. Configurar Chaves de Segurança (CRÍTICO) ⚠️

As chaves do Supabase **não são versionadas por segurança**. Portanto, é necessário criá-las manualmente.

### Passos:

 1. Acesse o diretório

   ```
   lib/core/services/
   ```

2. Crie o arquivo:

   ```
   supabase_options.dart
   ```

3. Insira o código abaixo, substituindo pelos dados do seu projeto Supabase:

```dart
// lib/core/services/supabase_options.dart
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseOptions = <Symbol, dynamic>{
  const Symbol('url'): 'SUA_URL_DO_SUPABASE_AQUI',
  const Symbol('anonKey'): 'SUA_ANON_KEY_DO_SUPABASE_AQUI',
};
```

> ⚠️ **Importante:** nunca versionar esse arquivo ou expor suas chaves publicamente.

---

## 🛠️ 3. Gerar Códigos (Build Runner)

O projeto utiliza **geração de código** para imutabilidade e injeção de dependência. Execute o comando abaixo sempre que necessário:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## ▶️ 4. Executar a Aplicação

### 📱 Mobile (Android / iOS)

Selecione um emulador ou dispositivo físico e execute:

```bash
flutter run
```

---

### 💻 Web (Login com Google)

O login via Google exige que a aplicação rode na **porta 3000**, conforme configurado no Google Console e no Supabase.

#### Opção 1 — VS Code

* Acesse a aba **Run and Debug**
* Selecione: **TaViajando (Web Port 3000)**

#### Opção 2 — Terminal

```bash
flutter run -d chrome --web-port 3000
```

---

## 🗄️ Banco de Dados (Supabase)

### 📋 Tabelas Necessárias

* `profiles`
* `trips`
* `tasks`
* `trip_participants`

### 📁 Storage Buckets

* `trip_covers` (Público)
* `avatars` (Público)

### 🔒 Políticas de Segurança (RLS)

* Habilitar **UPDATE** na tabela `trips` para usuários autenticados.

---

## 🎓 Observações Finais

Projeto desenvolvido com fins **acadêmicos**, no curso de **Sistemas de Informação**, utilizando **Flutter** e **Supabase** como stack principal.

---
## ✍️ Autoria

Este projeto foi desenvolvido por:

- Samuel Santos
Estudante de Sistemas de Informação – UFBA.
GitHub: [samucaasantos](https://github.com/samucaasantos)

- Lucas longo
Estudante de Sistemas de Informação – UFBA.
GitHub: [nsllongo](https://github.com/nsllongo)

- Hugo Miguel
Estudante de Sistemas de Informação – UFBA.
GitHub: [hmigl](https://github.com/hmigl)

- Jorge Ferreira
Estudante de Sistemas de Informação – UFBA.
GitHub: [Jorgefrgs](https://github.com/Jorgefrgs)

- Cauã Lima
Estudante de Sistemas de Informação – UFBA.
GitHub: [cauasntlima](https://github.com/cauasntlima)

## 📄 Licença

Este projeto é distribuído sob a licença MIT.
