# forvulkan
 You got Vulkan in my Fortran!

I have no idea what I'm doing.

![Womp womp womp womp](https://media.tenor.com/A_5FXBGEjkYAAAAM/yes.gif)

Something something deep quote about bringing the newest graphics api into the oldest language blah blah.

Join my discord for questions: https://discord.gg/D95q7BHUE4

-----

### Note:

-----

So GCC Gfortran is stuck at a 63 character variable name limit.

I had to get creative to allow the Vulkan constants to be accessed in the same manor you can get them in the C docs.

AKA: Don't blame me man I'm just trying to bring this thing into fortran.

-----



This program will probably blow up if you try to run it, but if you want to run it:

### Arch

```
yay -S vulkan-devel glfw shaderc
```

If you have an amd gpu:

```
yay -S vulkan-radeon
```

Probably missing something there.

Let me know if it blows up, thanks.

## Note:
MacOS will need MoltenVK. This is probably going to be a pain.