return {
	name='breakup',
	version='0.1.0',
	description='Breakup is an advanced testing framework for Lua.',
	authors={
		'Rolf van Kleef <breakup@rolfvankleef.nl>',
	},
	license='Apache 2.0',
	dependencies={
		lua=">= 5.1,<5.4",
		argparse=">=0.1.0,<0.2.0",
		harmonize="==0.1.0"
	},
	recommendedDependencies={
		luacov=">=0.12.0,<0.13.0",
		luasocket=">=2.0,<4.0",
		luaposix=">=34.0.0,<35.0.0"
	},
	scripts={
		test=function(...)
			local breakup, err = require"breakup.runner"
			breakup:add_suite("breakup.assertions_test")
			return breakup:run({...})
		end,
	},
}
