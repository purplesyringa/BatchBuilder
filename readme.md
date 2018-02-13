# BatchBuilder v1.0
(c) 2018 Ivanq

**BatchBuilder is a build system for BAT/CMD files.**


## Example of usage

First:
1. Copy `build.cmd` and the `compiler` directory somewhere.
2. Create directory `src` and add some `entry.cmd` file inside. `entry.cmd` is your BAT file.

After some changes:
1. Run `build.cmd`.
2. Directory `dist` with a script `bootstrap.cmd` will appear, run it..


## Settings

File `build.ini` can be created inside `src` directory to control BatchBuilder. The following options can be used:

1. `entry=<filename>`
   Default value: `entry.cmd`

   The script that will be ran on start.

2. `delete_compiled=yes/no`
   Default value: `yes`

   Whether to remove compiled BAT-files. If `no` is choosen, compiled code will be held in `compiler\compiled` directory.

3. `compile_if=<rules>`
   Default value: `batch ~-4 .cmd,batch ~-4 .bat`

   Sets which files will be handled by BatchBuilder.

   The rules are separated by comma. The rules (`~-4 .cmd` and `~-4 .bat`) are made of compiler name (`batch`), key (`~-4`) and value (`.cmd` and `.bat`).

   If the key starts with a tilda (~), and the following number is negative (-4), then the latest `-n` characters (4) will be checked. If the number is positive, all the characters except the first `n` will be checked. Later choosen characters are checked against value.

   If the key doesn't start with a tilda, the rule is a replace rule. For example, the key `a=b` means `replace all A's with B's and then compare to value`.

   Example:
    `batch ~-4 .cmd,batch ~-4 .bat`
    Handle all files which have `.cmd` or `.bat` as the last 4 characters (i.e. have `cmd` or `bat` extension) with `batch` compiler.

   Example:
    `batch o=a hello.bat`
    Handle all files with name = `hello.bat` or `hella.bat` with `batch` compiler.

4. `packed=<yes/no/local>`
   Default value: `yes`

   Sets whether BatchBuilder should pack the project to a single file.

   If the value is `no`, file `bootstrap.cmd` and the `contents` folder with compiled scripts will be created. When ran, the `contents` folder will be copied to `%TEMP%`.

   If the value is `local`, `bootstrap.cmd` and `contents` will also be created, but the script will be ran from `contents`, not `%TEMP%`.

   And if the value is `yes`, `bootstrap.cmd` will contain an unpacker and an archive, and the script will be ran from `%TEMP%`.


## BatchBuilder compiler

To simplify work, BatchBuilder introduce modules. A module is just a BAT-file. Here is an example a module:

```
+------------------------------------------------+
| hi.bat                                         |
+------------------------------------------------+
| export say_hello                               |
|  echo Hello                                    |
| end export                                     |
+------------------------------------------------+
```

Let's save it to `src` directory. Now let's write a script using `say_hello`:

```
+------------------------------------------------+
| entry.cmd                                      |
+------------------------------------------------+
| import say_hello                               |
+------------------------------------------------+
```

BatchBuilder compiler will replace `import say_hello` with `echo Hello`.


## Method arguments

When calling `import say_hello`, we could pass additional data, for example, a name:

```
+------------------------------------------------+
| entry.cmd                                      |
+------------------------------------------------+
| import say_hello Kirill                        |
| import say_hello Vanya                         |
+------------------------------------------------+
```

Then the first value can be accessed as `%1`, the second as `%2`, and so on.

```
+------------------------------------------------+
| hi.bat                                         |
+------------------------------------------------+
| export say_hello                               |
|  echo Hello, %1!                               |
| end export                                     |
+------------------------------------------------+
```

Some parameters can be named, then `%1`, `%2` etc. will mean "1/2 argument after last named":

```
+------------------------------------------------+
| hi.bat                                         |
+------------------------------------------------+
| export say_hello name                          |
|  echo Hello, %name%!                           |
| end export                                     |
+------------------------------------------------+
```


Modules can be useful for simple tasks, for example, delete question.

```
+------------------------------------------------+
| delete.cmd                                     |
+------------------------------------------------+
| export delete_dir dir                          |
|  set /p agree=Do you want to delete %dir%?     |
|  if "%agree%" == "yes" (                       |
|   rmdir /S /Q %1                               |
|  )                                             |
| end export                                     |
+------------------------------------------------+
```

```
+------------------------------------------------+
| entry.cmd                                      |
+------------------------------------------------+
| import delete_dir Documents                    |
| import delete_dir Desktop                      |
| import delete_dir Pictures                     |
| import delete_dir Music                        |
+------------------------------------------------+
```


## Returning values

BatchBuilder's `batch` compiler also supports operator `return` inside `export` blocks to return values from methods. To save returned value `import -> variable command` syntax can be used.

```
+------------------------------------------------+
| delete.cmd                                     |
+------------------------------------------------+
| export ask q                                   |
|  set /p result=%q%?                            |
|  return %result%                               |
| end export                                     |
|                                                |
| export delete_dir                              |
|  import -> agree ask "Delete %1"               |
|  if "%agree%" == "yes" (                       |
|   rmdir /S /Q %1                               |
|  )                                             |
| end export                                     |
+------------------------------------------------+
```


## Global variables

By default, variables defined in one function cannot be accessed from another function or recursion call of the same function.

```
+------------------------------------------------+
| local_vars.cmd                                 |
+------------------------------------------------+
| export a                                       |
|  echo Enter A                                  |
|  import b                                      |
|  echo Read local variable my_var from A        |
|  echo my_var=%my_var%                          |
|  echo Exit A                                   |
| end export                                     |
|                                                |
| export b                                       |
|  echo Enter B                                  |
|  echo Set local variable my_var                |
|  set my_var=hello                              |
|  echo Read local variable my_var from B        |
|  echo my_var=%my_var%                          |
|  echo Exit B                                   |
| end export                                     |
|                                                |
| import a                                       |
+------------------------------------------------+
| Enter A                                        |
| Enter B                                        |
| Set local variable my_var                      |
| Read local variable my_var from B              |
| my_var=hello                                   |
| Exit B                                         |
| Read local variable my_var from A              |
| my_var=                                        |
| Exit A                                         |
+------------------------------------------------+
```

Though sometimes you may want to set a variable for all functions. `global` keyword can be used for this.

```
+------------------------------------------------+
| global_vars.cmd                                |
+------------------------------------------------+
| export a                                       |
|  echo Enter A                                  |
|  import b                                      |
|  echo Read global variable my_var from A       |
|  echo my_var=%my_var%                          |
|  echo Exit A                                   |
| end export                                     |
|                                                |
| export b                                       |
|  echo Enter B                                  |
|  echo Set global variable my_var               |
|  global my_var=hello                           |
|  echo Read global variable my_var from B       |
|  echo my_var=%my_var%                          |
|  echo Exit B                                   |
| end export                                     |
|                                                |
| import a                                       |
+------------------------------------------------+
| Enter A                                        |
| Enter B                                        |
| Set global variable my_var                     |
| Read global variable my_var from B             |
| my_var=hello                                   |
| Exit B                                         |
| Read global variable my_var from A             |
| my_var=hello                                   |
| Exit A                                         |
+------------------------------------------------+
```


## Export directives

A command like `@directive <something>` can go between `export`, which means "set `@something` directive for the current function". You can set several directives at once: for example: `@directive <something> <something2>`.

1. `@safe_recursion`

   By default, a new context is created to use local variables. To fasten it, `setlocal` and `endlocal` commands are used. However, `setlocal` has depth limit.

   If you don't need the limit, it makes sense to use `@safe_recursion` directive which stores and loads variables using files, not `setlocal` and `endlocal`. However, `@safe_recursion` can slow the script.

2. `@follow_local`

   To make coding easier, all caller's variables are removed, and after returning they are restored. For example:

```
+------------------------------------------------+
| non_local.cmd                                  |
+------------------------------------------------+
| export a                                       |
|  echo Enter A                                  |
|  echo Set my_var=hello                         |
|  set my_var=hello                              |
|  import b                                      |
|  echo Exit A                                   |
| end export                                     |
|                                                |
| export b                                       |
|  echo Enter B                                  |
|  echo Read local variable my_var               |
|  echo my_var=%my_var%                          |
|  echo Exit B                                   |
| end export                                     |
|                                                |
| import a                                       |
+------------------------------------------------+
| Enter A                                        |
| Set my_var=hello                               |
| Enter B                                        |
| Read local variable my_var                     |
| my_var=                                        |
| Exit B                                         |
| Exit A                                         |
+------------------------------------------------+
```

   However, to make recursion calls faster, `@follow_local` directive can be used, if empty variables don't have special meaning:

```
+------------------------------------------------+
| local.cmd                                      |
+------------------------------------------------+
| export a                                       |
|  echo Enter A                                  |
|  echo Set my_var=hello                         |
|  set my_var=hello                              |
|  import b                                      |
|  echo Exit A                                   |
| end export                                     |
|                                                |
| @directive follow_local                        |
| export b                                       |
|  echo Enter B                                  |
|  echo Read local variable my_var               |
|  echo my_var=%my_var%                          |
|  echo Exit B                                   |
| end export                                     |
|                                                |
| import a                                       |
+------------------------------------------------+
| Enter A                                        |
| Set my_var=hello                               |
| Enter B                                        |
| Read local variable my_var                     |
| my_var=hello                                   |
| Exit B                                         |
| Exit A                                         |
+------------------------------------------------+
```

   You can fasten your script by using `@follow_local` and unsafe recursion.


## Classes and objects

`batch` compiler supports classes. To create a class, `class`/`end class` commands are used:

```
+------------------------------------------------+
| class.cmd                                      |
+------------------------------------------------+
| class ClassTest                                |
| end class                                      |
+------------------------------------------------+
```

Methods can be added using `export` command.

```
+------------------------------------------------+
| class.cmd                                      |
+------------------------------------------------+
| class ClassTest                                |
|  export say_hello                              |
|   echo Hello, %1!                              |
|  end export                                    |
|  export say_bye                                |
|   echo Bye, %1!                                |
|  end export                                    |
| end class                                      |
+------------------------------------------------+
```

`new` keyword is used to create a class, and call/import can be done using a new instance:

```
+------------------------------------------------+
| class.cmd                                      |
+------------------------------------------------+
| echo Create ClassTest and put it to my_class   |
| new -> my_class ClassTest                      |
|                                                |
| echo Call say_hello and then say_bye           |
| import %my_class%.say_hello Ivan               |
| import %my_class%.say_bye Ivan                 |
+------------------------------------------------+
```

It should be noticed that objects are created in heap, so they aren't linked to variable name. That means that instances are passed by reference.

```
+------------------------------------------------+
| reference_class.cmd                            |
+------------------------------------------------+
| export by_reference                            |
|  echo Inside: %1                               |
| end export                                     |
|                                                |
| new -> my_class ClassTest                      |
| echo Outside: %my_class%                       |
| import by_reference %my_class%                 |
+------------------------------------------------+
| Outside: __instance_343654654__                |
| Inside: __instance_343654654__                 |
+------------------------------------------------+
```


## Class fields

`%this%` variable can be used inside methods, having a link to current instance:

```
+------------------------------------------------+
| class.cmd                                      |
+------------------------------------------------+
| class ClassTest                                |
|  export save                                   |
|   set "%this%.data=%~1"                        |
|   echo Saved %~1                               |
|  end export                                    |
|                                                |
|  export load                                   |
|   call set "data=%%%this%.data%%"              |
|   return %data%                                |
|  end export                                    |
|                                                |
|  export echo                                   |
|   import -> data %this%.load                   |
|   echo Loaded %data%                           |
|  end export                                    |
| end class                                      |
|                                                |
| new -> instance ClassTest                      |
| import %instance%.save One                     |
| import %instance%.echo                         |
+------------------------------------------------+
| Saved One                                      |
| Loaded One                                     |
+------------------------------------------------+
```


## Magic methods

Sometimes non-standard operations should be done without calling `import`. Magic methods can be used for this.

1. `magic_init`

   Called when `new` operator is used. Arguments can be passed via `new` command:

```
+------------------------------------------------+
| magic.cmd                                      |
+------------------------------------------------+
| class ClassTest                                |
|  export magic_init                             |
|   echo Created %~1                             |
|  end export                                    |
| end class                                      |
|                                                |
| new -> instance ClassTest "for test"           |
+------------------------------------------------+
| Created for test                               |
+------------------------------------------------+
```


## Working examples

Examples named like `src-admin`, `src-alert` and so on are distributed with BatchBuilder. To run them, rename the folder to `src`, run `build.cmd` and then `dist\bootstrap.cmd`.