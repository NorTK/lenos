==========================
CentOS Stream 10 TacOS NorTK PoC
==========================
---------------------------------------
TacOS: Live USB de CentOS Stream 10 con branding para NorTK
---------------------------------------

Descripción
===========
Un recetario para poder generar imágenes ISO (Live y de Instalación) de CentOS Stream 10.


Pre-requisitos
==============
* Fedora 43 o CentOS Stream 10
* kiwi-ng
* GNU make
* qemu-kvm (para pruebas)


Instrucciones
=============
Para construir las imágenes, necesitarás poner estos archivos en un usuario con poderes de sudo.

Para instalar los paquetes necesarios, como root:

.. code-block:: sh

    # instalar requerimientos
    dnf -y install kiwi-cli make qemu-img qemu-kvm edk2-ovmf

Una vez instalados los paquetes, necesitamos crear un usuario normal con poderes de sudo:

.. code-block:: sh

    # agregar al usuario
    useradd renich

    # agregarlo al grupo de wheel
    usermod -aG wheel renich

Luego, te haces el usuario y te vas al directorio que contiene estos archivos y corres los siguientes comandos:

.. code-block:: sh

    # ir a donde está el código
    cd ~/src/cs10-nortk

Construcción
------------

.. code-block:: sh

    # construir el live ISO
    sudo make build-live

    # construir la imagen de disco (OEM/Instalación)
    sudo make build-disk

Pruebas
-------

Para probar las imágenes generadas, puedes usar los siguientes comandos de make.

Para la versión Live:

.. code-block:: sh

    make test-live

Para la versión de disco (Instalación):

.. code-block:: sh

    make test-disk

Nota: ``make test-disk`` creará automáticamente un disco virtual temporal de 20GB (``test-disk.qcow2``) y lo eliminará al finalizar la prueba.

Para seguir el proceso de construcción, en otra sesión, puedes usar: ``tail -F result-*/build/image-root.log`` en el directorio en donde iniciaste el proceso.

Limpieza
--------

Para limpiar los archivos temporales de construcción:

.. code-block:: sh

    sudo make clean

Para eliminar todos los resultados (incluyendo las imágenes ISO generadas):

.. code-block:: sh

    sudo make distclean


Referencias
===========
* https://osinside.github.io/kiwi/
* https://youtu.be/RKeFR4R2IeA
* https://pagure.io/centos-kiwi-examples
