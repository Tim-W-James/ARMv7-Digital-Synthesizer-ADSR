<!--
*** Based on the Best-README-Template: https://github.com/othneildrew/Best-README-Template
***
*** To avoid retyping too much info. Do a search and replace for the following:
*** repo_name, project_title, project_description
-->



<!-- PROJECT LOGO -->
<br />
<p align="center">

  <h2 align="center">ARMv7 Digital Synthesizer ADSR</h2>

  <p align="center">
    Digital synthesizer with ADSR (attack-decay-sustain-release) envelope functionality.
    <br />
    This project was created during my university studies at <b>ANU</b> in <b>2020</b> and has been transferred from the ANU GitLab server.
    <br />
    <a href="https://github.com/Tim-W-James/ARMv7-Sine-Wave/blob/part-2/design-document.pdf"><strong>Read the design doc »</strong></a>
    <br />
<!--     <a href="https://github.com/Tim-W-James/repo_name">View Demo</a> -->
<!--     ·
    <a href="https://github.com/Tim-W-James/repo_name/issues">Report Bug</a> -->
<!--     ·
    <a href="https://github.com/Tim-W-James/repo_name/issues">Request Feature</a> -->
  </p>
</p>



<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#features">Features</a></li>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
        <a href="#usage">Usage</a>
    </li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

<!-- [![Product Name Screen Shot][product-screenshot]](https://example.com) -->

Program that implements digital synthesizer with (attack-decay-sustain-release) envelope functionality in ARMv7 assembly. Builds upon my [sine wave program](https://github.com/Tim-W-James/ARMv7-Sine-Wave). Read the [design doc](https://github.com/Tim-W-James/ARMv7-Sine-Wave/blob/part-2/design-document.pdf) for implementation details.

### Features
Waveforms can be customized with the following:
* Custom frequency
* Sustain loudness
* Peak loudness
* Attack duration
* Delay duration
* Sustain duration
* Release duration

### Built With

* ARMv7 Assembly
* [stm32l476 discovery board](https://www.digikey.com.au/en/products/detail/stmicroelectronics/STM32L476G-DISCO/5344355)

<!-- GETTING STARTED -->
## Usage

* Requires the use of an [stm32l476 discovery board](https://www.digikey.com.au/en/products/detail/stmicroelectronics/STM32L476G-DISCO/5344355). This is a physical device that can be connected to a PC and interfaces with VSCode.
* Visual Studio Code with the following [extensions](https://marketplace.visualstudio.com/items?itemName=comp2300-anu.comp2300-extension-pack):
  - ARM
  - C/C++
  - YAML
  - COMP2300's Cortex-Debug



<!-- CONTACT -->
## Contact

Email: [tim.jameswork9800@gmail.com](mailto:tim.jameswork9800@gmail.com "tim.jameswork9800@gmail.com")

Project Link: [https://github.com/Tim-W-James/ARMv7-Sine-Wave](https://github.com/Tim-W-James/ARMv7-Sine-Wave)



<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements

* Australian National University for VSCode framework and project skeleton
