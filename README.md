# forvulkan
 You got Vulkan in my Fortran!

I have no idea what I'm doing.

![Womp womp womp womp](https://media.tenor.com/A_5FXBGEjkYAAAAM/yes.gif)

Something something deep quote about bringing the newest graphics api into the oldest language blah blah.

Join my discord for questions: https://discord.gg/D95q7BHUE4

-----

### Note:

-----

This needs gfortran 14+. :T

So GCC Gfortran is stuck at a 63 character variable name limit.

I had to get creative to allow the Vulkan constants to be accessed in the same manor you can get them in the C docs.

AKA: Don't blame me man I'm just trying to bring this thing into fortran.

-----

### This is not ready for testing, production, anything. I'm still writing it from the ground up!

-----


This program will probably blow up if you try to run it, but if you want to run it:

# Install instructions I guess.

## Arch

```
yay -S vulkan-devel glfw shaderc
```

If you have an amd gpu:

```
yay -S vulkan-radeon
```

## Ubuntu 24.10 Arm64 - (raspberry pi 5)

You're gonna have to build fpm from source! But it works without any trouble.

```
git clone https://github.com/fortran-lang/fpm
```

Then you will just have to install:

```
sudo apt install gfortran
```

Then you will have to run the install script in the root of the fpm folder:

```
./install.sh
```

Then just move it to the /usr/bin/ folder so you don't have to deal with any nonsense.

Now we can get to the actual dependency installs.

```
sudo apt install libglfw3-dev vulkan-tools libvulkan-dev vulkan-validationlayers spirv-tools libshaderc-dev
```

Switch the link settings from arch to ubuntu arm64 in the fpm.toml

-----

Probably missing something there.

Let me know if it blows up, thanks.

## Note:
MacOS will need MoltenVK. This is probably going to be a pain.

## Note:
If this ridiculous readme didn't drive you away, thanks for checking out my project :D
