> config mail lib
> find local mail thingy
> tests
  > model
    > account
      > save
      > update
      > destroy
      > confirm
      > reset password
  > controllers
    > sessions
      > new
      > create
      > destroy
    > accounts
      > new
      > create
      > edit
      > update
      > delete
      > confirm
      > forgot pass
      > reset password page
      > reset password

> controllers
  > sessions
    > new
    > create
    > destroy
  > accounts
    > new
    > create
    > edit
    > update
    > delete
    > confirm
    > forgot pass
    > reset password page
    > reset password

> views
  > layouts
    > bootstrap layout
      > header
        > logo
        > new account 
        > if logged in
          > logout
          > edit account 
  > accounts
    > new
    > form
    > edit
    > confirmed
    > forgot pass
    > set new pass
    > reset pass

> wrap controller routes so url helpers work

> make sure boot works
> get the controllers added
> remove admin
> add mailers
> go over code
> DB seeds
> Revise.from attribute

> mailers
  > confirmable
  > recoverable 
  > views
    > confirmation_instructions
    > reset_password_instructions

> add revise locale
> set domain
> set Revise.from
> make sure starts
> tests bootstrapping
> create account working
> DB seeds working
> tests working
  > models
  > controllers
    > sessions
    > accounts

> split out revise
  > revise autoloads