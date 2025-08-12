# Nix Deployments

This repository manages Nix-based deployments for various services and applications, primarily focusing on a home lab setup. 
It leverages NixOS modules, `deploy-rs` for remote deployments, and integrates with tools like Docker Compose via `compose2nix`.
It extend systems defined in my [dotfiles](https://github.com/PieterPel/dotfiles) repository with deploy-specific setup.

## Project Structure

*   **`.envrc`**: Direnv configuration for setting up the development environment.
*   **`flake.lock`**: Locks the versions of Nix inputs.
*   **`flake.nix`**: The main entry point for the Nix flake, defining inputs, outputs, and system configurations.
*   **`LICENSE`**: Project license.
*   **`README.md`**: This file.
*   **`derivations/`**: Contains Nix derivations for building specific applications.
    *   `perhaps.nix`: Derivation for the 'perhaps' application, built using `compose2nix`.
*   **`helpers/`**: Contains reusable Nix functions and modules.
    *   `compose.nix`: Helper for creating Nix packages from Docker Compose files using `compose2nix`.
    *   `nginx-proxy.nix`: Reusable logic for Nginx reverse proxy configurations.
    *   `system.nix`: Provides helper functions for `deploy-rs` (e.g., `mkNode`, `mkAppProfile`, `mkNixOS`).
    *   `user.nix`: Helper for creating application-specific users.
*   **`modules/`**: Contains NixOS modules for configuring various services.
    *   `app-users.nix`: Defines application-specific users.
    *   `default.nix`: Imports all other modules.
    *   `deploy-user.nix`: Configures the 'deploy' user by `deploy-rs`.
    *   `grafana.nix`: Configures Grafana for monitoring.
    *   `host-data.nix`: Defines host-specific data and roles (e.g., `logsHoster`, `perhapsHoster`).
    *   `loki.nix`: Configures Loki for log aggregation.
    *   `options.nix`: Defines configurable options for the deployment (e.g., ports, host roles).
    *   `prometheus.nix`: Configures Prometheus for metrics collection.
    *   `promtail.nix`: Configures Promtail for shipping logs to Loki.
    *   `nginx/` (directory): Nginx-related configurations.
        *   `base.nix`: Basic Nginx settings.
        *   `default.nix`: Imports other Nginx modules.
        *   `logs.nix`: Nginx proxy configurations for logging services (Grafana, Prometheus, Loki, Promtail).
        *   `options.nix`: Nginx-specific options.
        *   `perhaps.nix`: Nginx proxy configuration for the 'perhaps' application.
*   **`nodes/`**: Defines specific host configurations.
    *   `host-data.nix`: Centralized host IP and system information.
    *   `nixberry.nix`: Configuration for the 'nixberry' host, including its NixOS configuration and `deploy-rs` profiles.

## Key Components and Features

### `flake.nix`
**Outputs**: 
*   `nixosConfigurations`: Defines NixOS system configurations (e.g., `nixberry`).
*   `deploy.nodes`: Configures nodes for `deploy-rs` deployments.
*   `checks`: Includes pre-commit checks (nixpkgs-fmt, nil, flake-checker) and `deploy-rs` checks.
*   `devShells`: Provides a development shell with pre-commit hooks enabled.
*   `formatter`: Sets `nixpkgs-fmt` as the default formatter.

## Deployment

This repository uses `deploy-rs` for deploying configurations to remote hosts. 
The `flake.nix` defines `deploy.nodes` which `deploy-rs` uses to understand the deployment targets and their associated profiles (e.g., `system`, `perhaps`).

## Code Quality

Pre-commit hooks are integrated via `git-hooks.nix` to ensure code quality and consistency. 
This includes `nixpkgs-fmt` for formatting, `nil` for Nix language server checks, and `flake-checker` for flake integrity.

## Getting Started

1.  **Clone the repository.**
2.  **Ensure Nix and `deploy-rs` are installed.**
4.  **Deploy applications using `deploy-rs`, e.g.:**
    ```bash
    deploy-rs .#nixberry
    ```

