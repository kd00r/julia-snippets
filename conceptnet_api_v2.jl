using JSON
using Word2Vec

#timer stuff
using TimerOutputs
const to = TimerOutput()
nanosec_to_sec = 0
#already_knocked = 0

#generic api functions
function knock_vectors()
    println("Initializing... ETA 65s...")
    println("knock_vectors() = loading vectors...")
    model = wordvectors("data/numberbatch-en.txt")
    println("knock_vectors() = loading vocab...")
    words = vocabulary(model)
    println("knock_vectors() = done!")
    #already_knocked = 1
    return model, words
end

#=
#model, words = knock_vectors(); #dirty setup of vector engine
model, words = @timeit to "vec_setup" knock_vectors();
time_knock = convert(Int64, TimerOutputs.time(to["vec_setup"]))
nanosec_to_sec = round(time_knock / 1000000000)
print("Vector engine up, took " * string(nanosec_to_sec) * "seconds") #convert to seconds for readability
=#

function get_cn_data(query_word, result_limit)
    ##conceptnet endpoint
    #concatenate in julia is "*"
    response_cn = make_API_call("https://api.conceptnet.io/c/en/" * query_word * "?offset=0&limit=" * result_limit)

    return response_cn
end

function get_dm_jja_data(query_word, result_limit)
    ##conceptnet endpoint
    #concatenate in julia is "*"
    response_dm_jja = make_API_call("https://api.datamuse.com/words?rel_jja=" * query_word * "&max=" * result_limit)

    return response_dm_jja
end

function get_dm_jjb_data(query_word, result_limit)
    ##conceptnet endpoint
    #concatenate in julia is "*"
    response_dm_jjb = make_API_call("https://api.datamuse.com/words?rel_jjb=" * query_word * "&max=" * result_limit)

    return response_dm_jjb
end

#genie setup
using Genie
import Genie.Router: route
import Genie.Renderer.Json: json

Genie.config.run_as_server = true

#genie routes
route("/") do
    (:message => "Hi there!") |> json
end

#example url:
#http://127.0.0.1:8000/vec?sim=1&a=cat&b=dog
#http://127.0.0.1:8000/vec?initinfo=true

#TODO: errors in this route, do not use
#=
route("/vec") do
    #init_time = params(:initinfo, "false")
    sim_score = params(:sim, "false")
    word_a = params(:a)
    word_b = params(:b)
    #=
    if init_time == "true"
        tmp_json = JSON.parse(string(nanosec_to_sec))
        #(:message => tmp_json) |> json #jsonify response and send it
    end
    =#
    if sim_score == "true"
        tmp_json = JSON.parse(string(similarity(model, word_a, word_b)))
        (:cosine_similarity => tmp_json) |> json #jsonify response and send it
    elseif sim_score == "false"
        println("no similarity requested.")
        tmp_json = JSON.parse("nothing to do!")
        (:message => tmp_json) |> json #jsonify response and send it
    end
    #tmp_json = JSON.parse("404") #default to 404
end
=#

#example urls:
#http://127.0.0.1:8000/api?type=cn&query=dog&limit=3
#http://127.0.0.1:8000/api?type=dm_jja&query=dog&limit=3
route("/api") do
    query_type = params(:type, "cn")
    query_word = params(:query, "example")
    query_limit = params(:limit, 1)
    if query_type == "cn"
        tmp_json = JSON.parse(get_cn_data(query_word, query_limit))
    elseif query_type == "dm_jja"
        #nouns that are often described by the adjective query_word
        #Popular nouns modified by the given adjective, per Google Books Ngrams
        tmp_json = JSON.parse(get_dm_jja_data(query_word, query_limit))
    elseif query_type == "dm_jjb"
        #adjectives that are often used to describe query_word
        #Popular adjectives used to modify the given noun, per Google Books Ngrams
        tmp_json = JSON.parse(get_dm_jjb_data(query_word, query_limit))
    else
        tmp_json = JSON.parse("404") #default to 404
    end
    (:message => tmp_json) |> json #jsonify response and send it
end

#start genie with persistence
Genie.startup()


using HTTP
function make_API_call(url)
    try
        response = HTTP.get(url)
        return String(response.body)
    catch e
        return "Error occurred : $e"
    end
end


#=
#conceptnet
data_cn = JSON.parse(response_cn)
edges = data_cn["edges"]
edge1 = edges[1]
edge2 = edges[2]
#length(edges) # same length as &limit= parameter above

#datamuse
data_dm_jja = JSON.parse(response_dm_jja)
data_dm_jjb = JSON.parse(response_dm_jjb)

#length(data_dm_jja)
#length(data_dm_jjb)
=#