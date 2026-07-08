# Blue-Carbon Manglar Tumbes 🌊🦀
### Multijurisdictional Blue Carbon Credit Tokenization Platform on LACNet

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Blue-Carbon Manglar Tumbes** es una plataforma descentralizada multijurisdiccional diseñada para tokenizar créditos de carbono azul provenientes de la conservación y restauración de manglares en la costa del Pacífico Latinoamericano (Perú, Ecuador y Colombia). Implementado sobre la red **LACNet**, el sistema automatiza el cumplimiento regulatorio transfronterizo utilizando el **Token Taxonomy Framework (TTF)** e integra tecnologías de frontera (Drones, IA y Blockchain) para empoderar financieramente a las comunidades pesqueras artesanales.

---

## 📌 Contenido del Repositorio

El repositorio se organiza de la siguiente manera:

*   📂 [`/contracts`](./contracts): Contratos inteligentes en Solidity (`MangroveCarbonToken.sol`) con implementación completa de especificaciones TTF y `BaseRelayRecipient`.
*   📂 [`/scripts`](./scripts): Scripts automatizados de despliegue y configuración para la testnet de LACNet.
*   📂 [`/python-alternative`](./python-alternative): Entorno de simulación offline en Python para demostraciones técnicas y pruebas de emisión sin conectividad.
*   📂 [`/tests`](./tests): Suite de pruebas unitarias y de integración para las funciones de tokenización multijurisdiccional.
*   📂 [`/docs`](./docs): Guías detalladas de despliegue, arquitectura de software y especificaciones de las APIs regulatorias.

---

## 🚀 Características Clave

### 1. Alineación con Estándares de la Hackathon
*   **Global Specification Automation (GSA):** Interfaz compatible con TTF que adapta dinámicamente sus atributos de datos para cumplir con las normativas ambientales de Perú (MINAM), Ecuador (MAE) y Colombia (MADS).
*   **Multi-Nation Token Creation (MNT):** Emisión transfronteriza unificada mediante contratos inteligentes eficientes que reducen la fricción del intercambio de activos climáticos entre naciones vecinas.
*   **International Compliance and Reporting (ICR):** Canal de datos inmutable (Drones/IoT ➡️ Oráculo ➡️ Blockchain) respaldado por almacenamiento descentralizado en **IPFS** para auditorías 24/7 conformes a estándares como Verra y Plan Vivo.

### 2. Tokenomics de Triple Valor y Economía Circular (3R)
El token no solo representa carbono; encapsula un modelo sostenible para el ecosistema:
*   **Reducción de emisiones:** Desincentiva la deforestación de manglares al otorgar mayor valor económico a los ecosistemas conservados.
*   **Modelo de Distribución Justa:** El **55%** de los ingresos generados por la venta de tokens se distribuye directamente a las cooperativas pesqueras locales y comunidades custodias.
*   **Mecanismo Deflacionario:** Al reclamar la compensación de carbono por parte de una entidad, el token se retira permanentemente de la circulación (*burn*), dejando un registro transparente y auditable en la red.

---

## 🛠️ Stack Tecnológico

*   **DLT/Blockchain:** LACNet (Testnet)
*   **Lenguajes:** Solidity (v0.8.20), JavaScript (Node.js), Python 3.10
*   **Librerías Web3:** Web3.js, Ethers.js
*   **Almacenamiento:** IPFS (InterPlanetary File System) via Pinata
*   **Infraestructura de Gas:** Habilitado para meta-transacciones mediante gasless relayers (`BaseRelayRecipient`).

---

## 🔧 Requisitos Previos e Instalación

### Clonar el repositorio
```bash
git clone [https://github.com/](https://github.com/)[TU-USUARIO]/[TU-REPOSITORIO].git
cd [TU-REPOSITORIO]
