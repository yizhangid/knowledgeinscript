knowledgeinscript
=================
Here are scripts relate to my every day QA work at for IPA project (freeipa.org). They born to be open sourced since this is an open source project.

::Script Naming Stratage:: <topic>.<target>.<action>.<type>

    topic: ipa = ipa project related scripts
           rhel= red hat enterprise linux administration scripts
    target: ipa.user = user operations under ipa project
            ipa.server = ipa server operations unde ipa project
            ...
    action: ipa.user.add = add user operation under ipa project
            ipa.group.add = add group operation under ipa project
            ...
    type  : sh = shell script
            pl = perl script 
            ...

    example: ipa.user.add.sh : shell script that can add ipa user under ipa project

::Directory ./ipa ::
    has all ipa related commands. these are simple commands, it make ipa work a little easier

::Directory ./rhel::
    red hat enterprise linux related commands.
