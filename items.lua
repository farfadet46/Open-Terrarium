--block definitions
blocks = {
	{name = "air", image = "air.png", collide = false},   --id 1
	{name = "rock", image = "stone.png"}, --id 2
	{name = "dirt", image = "dirt.png"},    --id 3
	{name = "grass", image = "grass.png"},   --id 4
	{name = "water", image = "water.png", prop = "liquid", collide = false,water = true, placeable = true,mineable = false}, --id 5
	{name = "leaves", image = "leaves.png"},   --id 6
	{name = "tree", image = "tree.png", drop = 7, drop_amount = 1},   --id 7
	{name = "wood", image = "wood.png"},   --id 8
	{name = "woodenplanks", image = "woodenplanks.png"}, --id 9
}

items = {
	{	name = "air",
		image = "air.png",
		collide = false
		},   --id 1
		
}

list_nodes={
	{	name="tree",
		description="tronc d'arbre",
		image="tree.png",
		drop="tree",
		groups = 2 -- lent
		},
	{	name="leave",
		description="feuilles",
		image="leave.png",
		drop="leave",
		groups = 0 -- rapide
		},
	{
		name="dirt",
		description="Terre",
		image="dirt.png",
		drop="dirt",
		groups = 1 -- normal
		},
	{
		name="sand",
		description="Sable",
		image="sand.png",
		drop="sand",
		groups = 0 -- rapide
		},
	{
		name="cobble",
		description="Pierres",
		image="cobble.png",
		drop="cobble",
		groups = 2 -- lent
		},
	{
		name="stone",
		description="Rocher",
		image="stone.png",
		drop="cobble",
		groups = 3 -- très lent
		},
	{
		name="tree",
		description="Tronc d'arbre",
		image="tree.png",
		drop="tree",
		groups = 2 -- lent
		},
	{
		name="wood",
		description="Planches de bois",
		image="wood.png",
		drop="wood",
		groups = 1 -- normal
		}
	}
