return {
    label = 'Mission Row Police Station',
    sprite = 60,
    blip = vec(439.8, -982.7),
    components = {
        {
            name = "Captain's Stash",
            type = 'stash',
            point = vec(452.1, -973.5, 30.7),
            shared = true,
        },
        {
            name = 'Locker Room Stash',
            type = 'stash',
            point = vec(457.7, -989.1, 30.7),
            shared = true,
        },
        {
            name = "Captain's Office",
            type = 'management',
            sphere = vec(448.4, -973.1, 30.7),
            radius = 1,
        },
        {
            name = 'Locker Room',
            type = 'wardrobe',
            sphere = vec(451.1, -991.9, 30.7),
            outfits = true,
        },
        {
            name = 'Front Parking',
            type = 'parking',
            thickness = 5.0,
            vehicles = { automobile = true, bicycle = true, bike = true, quadbike = true },
            points = {
                vec3(459.0, -1013.0, 27.0),
                vec3(466.0, -1013.0, 27.0),
                vec3(466.0, -1022.0, 27.0),
                vec3(459.0, -1022.0, 27.0),
                vec3(459.0, -1027.0, 27.0),
                vec3(426.0, -1031.0, 27.0),
                vec3(428.0, -1012.0, 27.0),
                vec3(428.5, -993.5, 27.0),
                vec3(455.5, -993.5, 27.0),
                vec3(455.0, -1012.0, 27.0),
            },
            spawns = {
                vec(436.4, -996.7, 25.3, 179.7),
                vec(427.6, -1027.8, 28.6, 181.3),
                vec(463.2, -1015.4, 27.6, 88.0),
                vec(446.1, -1025.8, 28.2, 3.9),
                vec(452.2, -996.9, 25.3, 359.6),
                vec(447.5, -996.6, 25.3, 359.8),
                vec(463.3, -1019.2, 27.7, 90.8),
                vec(442.4, -1026.5, 28.3, 178.2),
                vec(438.8, -1026.9, 28.4, 181.6),
                vec(434.6, -1027.1, 28.4, 6.8),
                vec(431.4, -996.5, 25.3, 179.2),
                vec(455.1, -1025.0, 28.1, 66.5),
            },
        },
        {
            name = 'Back Parking',
            type = 'parking',
            thickness = 4.0,
            vehicles = { automobile = true, bicycle = true, bike = true, quadbike = true },
            points = {
                vec3(472.0, -1018.0, 28.0),
                vec3(479.0, -1018.0, 28.0),
                vec3(479.0, -1026.5, 28.0),
                vec3(468.0, -1027.0, 28.0),
            },
            spawns = {
                vec(474.8, -1019.6, 27.6, 89.3),
                vec(472.6, -1024.2, 27.7, 274.6),
            },
        },
    },
}
