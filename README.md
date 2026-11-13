<p align="center">
  <a href="https://escalated.dev"><img src="https://raw.githubusercontent.com/escalated-dev/escalated/main/docs/assets/readme/logo.png" width="72" height="72" alt="Escalated"></a>
</p>

<h1 align="center">Escalated for Flutter</h1>

<p align="center">
  Add a customer support area to your Flutter app.<br>
  Tickets, a knowledge base and guest access, talking to your Escalated backend's REST API.
</p>

<p align="center">
  <a href="https://escalated.dev"><b>Website</b></a> ·
  <a href="https://escalated.dev/docs"><b>Docs</b></a> ·
  <a href="https://escalated.dev/cloud"><b>Cloud</b></a> ·
  <a href="CHANGELOG.md"><b>Changelog</b></a>
</p>

<br>

## What it does

<table>
  <tr>
    <td width="50%" valign="top">
      <h3>Every support screen, ready to route</h3>
      Login, ticket list, ticket detail with replies and SLA timers, new ticket with attachments, and knowledge base screens you drop into your GoRouter tree.
    </td>
    <td width="50%" valign="top">
      <h3>Fits your app instead of fighting it</h3>
      Screens take colours from your app's ThemeData, light or dark, and auth hooks let you plug in the sign-in you already have.
    </td>
  </tr>
</table>

## Features

<table>
<tr>
<td width="33%" valign="top">

**Tickets**
- Create, view, filter and reply
- File attachments on tickets and replies
- SLA countdown timers on ticket detail

</td>
<td width="33%" valign="top">

**Self-service**
- Searchable knowledge base with HTML articles
- Post-resolution CSAT star ratings

</td>
<td width="33%" valign="top">

**Guest access**
- Tickets without an account
- Emailed code, expiring per-ticket access

</td>
</tr>
<tr>
<td width="33%" valign="top">

**Authentication**
- Override login, logout, register and token
- Built-in client with secure token storage

</td>
<td width="33%" valign="top">

**Flutter integration**
- Riverpod providers for auth, tickets, KB, theme
- GoRouter-compatible screens

</td>
<td width="33%" valign="top">

**Look and language**
- Takes your app's ThemeData, light or dark
- English, Spanish, French, Canadian French, German
- Configurable colour, radius, locale and API URL

</td>
</tr>
</table>

<p align="center"><sub><a href="docs/features.md">Every feature in detail</a></sub></p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter_3.16+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter 3.16+"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart_3.2+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart 3.2+"></a>
  <a href="https://riverpod.dev"><img src="https://img.shields.io/badge/Riverpod-00B4AB?style=for-the-badge" alt="Riverpod"></a>
</p>

## Quick start

Add the package to `pubspec.yaml`:

```yaml
dependencies:
  escalated:
    git:
      url: https://github.com/escalated-dev/escalated-flutter.git
```

Then wrap your app in `EscalatedPlugin` with your API base URL. The [installation guide](docs/installation.md) shows the full setup and every config option.

## Learn more

- [All features](docs/features.md) · [Installation and configuration](docs/installation.md)
- [Screens, widgets and models](docs/screens-and-widgets.md) · [State management](docs/state-management.md)
- [Authentication and guest access](docs/authentication.md) · [Guest access API changes](docs/guest-access.md)
- [Theming](docs/theming.md) · [Internationalization](docs/internationalization.md)
- [Escalated docs](https://escalated.dev/docs)

Escalated is also available for [React Native](https://github.com/escalated-dev/escalated-react-native), and as a web helpdesk for [Laravel](https://github.com/escalated-dev/escalated-laravel), [Rails](https://github.com/escalated-dev/escalated-rails), [Django](https://github.com/escalated-dev/escalated-django), [NestJS](https://github.com/escalated-dev/escalated-nestjs), [AdonisJS](https://github.com/escalated-dev/escalated-adonis), [Symfony](https://github.com/escalated-dev/escalated-symfony), [Phoenix](https://github.com/escalated-dev/escalated-phoenix), [Go](https://github.com/escalated-dev/escalated-go), [.NET](https://github.com/escalated-dev/escalated-dotnet), [Spring](https://github.com/escalated-dev/escalated-spring), [WordPress](https://github.com/escalated-dev/escalated-wordpress) and [Filament](https://github.com/escalated-dev/escalated-filament).

## License

MIT. Copyright (c) Escalated.dev. See [LICENSE](LICENSE).
