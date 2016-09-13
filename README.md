# Tiles

Tiles is a surface rendering grid for Processing, similar to first versions of SimCity, based on an external variable input

## Setup

Tiles are defined as JSON objects in a file, with all properties including texture and color code.

	{
		"id": 0,
		"name": "LAND",
		"aspect": {"render": "TEXTURE", "texture": "textures/land.png" },
		"colors":["WHITE", "WHITE", "WHITE", "WHITE"]
	}


Colors are also defined as JSON object in a file. Colors file must be shared both this sketch and reader sketch

	{
		"id": 0,
		"name": "WHITE",
		"value": {"original": "#FFF2F3FF", "adjusted": "#FFF2F3FF"},
		"binary": true
	} 

## Usage
	
Create a Tiles grid, specifying the settings files beforehand created. If no settings files are given, it will retrieve "colors.tsv" and "tiles.tsv" as default

	Tableau tableau = new Tableau("colors.json", "tiles.json");
	
	
Load input data whenever needed/desired (p.e. periodically or after a specific key press)

	tableau.update(msg);
		

Draw Tiles at given location and tileSize

	tableau.draw(width/2, height/2, 80);


# Message format

*msg* is a JSON object containing the grid structure and an array with every tile properties

	{
		"properties": {
			"columns": 3,
			"rows": 3
		},
		"tiles": [
			{
				"x": 0,
				"y": 0,
				"name": "LAND",
				"rotation": 0
			},
			{
				"x": 1,
				"y": 0,
				"name": "ROAD_X",
				"rotation": 0
			},
			...
		]
	}


## License

Tiles is released under the MIT License.