#My Julia solution to the printgrid exercise

function gen_grid_solid(size) #generate solid horizontal ceiling and corners
    print("+")
    print("--"^size) #two dashes "--" is usually the same width as a pipe "|" is in height.
    print("+")
    print("--"^size)
    println("+")
end

function gen_grid_walls(size) #generate vertical walls with space in between
    print("|")
    print("  "^size) #again, two spaces "  " for one pipe "|" to keep correct size
    print("|")
    print("  "^size)
    println("|")
end


function gen_grid(size)
    for j in 1:2 #do this block twice
        gen_grid_solid(size) #print ceiling
        for i in 1:size
            gen_grid_walls(size) #print walls
        end
    end
    gen_grid_solid(size) #print last floor
end

#print the grid a few times
gen_grid(1)
gen_grid(2)
gen_grid(3)
gen_grid(5)
gen_grid(8)
gen_grid(13)
