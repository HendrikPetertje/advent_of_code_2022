# Run tests in order so we get a nice list of excersises
ExUnit.configure(seed: 0, trace: true, exclude: [:skip])
ExUnit.start()
