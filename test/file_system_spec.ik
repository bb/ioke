
use("ispec")

describe(FileSystem, 
  it("should have the correct kind", 
    FileSystem should have kind("FileSystem")
  )

  describe("exists?",
    it("should return false for something that doesn't exit", 
      FileSystem exists?("flux_flog") should == false
      FileSystem exists?("src/flux_flog") should == false
      FileSystem exists?("flux_flog/builtin") should == false
    )

    it("should return true for a file",
      FileSystem exists?("build.xml") should == true
      FileSystem exists?("src/builtin/A1_defaultBehavior.ik") should == true
    )

    it("should return true for a directory",
      FileSystem exists?("src") should == true
      FileSystem exists?("src/") should == true
      FileSystem exists?("src/builtin") should == true
    )
  )

  describe("file?",
    it("should return false for something that doesn't exit", 
      FileSystem file?("flux_flog") should == false
    )

    it("should return true for a file", 
      FileSystem file?("build.xml") should == true
    )

    it("should return true for a file inside of a directory", 
      FileSystem file?("src/builtin/A1_defaultBehavior.ik") should == true
    )

    it("should return false for a directory", 
      FileSystem file?("src") should == false
      FileSystem file?("src/") should == false
    )

    it("should return false for a directory inside another directory", 
      FileSystem file?("src/builtin") should == false
    )
  )

  describe("directory?", 
    it("should return false for something that doesn't exit", 
      FileSystem directory?("flux_flog") should == false
    )

    it("should return false for a file", 
      FileSystem directory?("build.xml") should == false
    )

    it("should return false for a file inside of a directory", 
      FileSystem directory?("src/builtin/A1_defaultBehavior.ik") should == false
    )

    it("should return true for a directory", 
      FileSystem directory?("src") should == true
      FileSystem directory?("src/") should == true
    )

    it("should return true for a directory inside another directory", 
      FileSystem directory?("src/builtin") should == true
    )
  )

  describe("createDirectory!",
    it("should signal an error if the directory already exists",
      fn(FileSystem createDirectory!("src")) should signal(Condition Error IO)

      bind(rescue(Condition, fn(c, nil)), ; ignore failures
        FileSystem removeDirectory!("test/newly_created_dir"))
    )

    it("should signal an error if a file with the same name already exists",
      fn(FileSystem createDirectory!("build.xml")) should signal(Condition Error IO)

      bind(rescue(Condition, fn(c, nil)), ; ignore failures
        FileSystem removeDirectory!("test/newly_created_dir"))
    )

    it("should create the directory",
      FileSystem createDirectory!("test/newly_created_dir")
      FileSystem should have directory("test/newly_created_dir")

      bind(rescue(Condition, fn(c, nil)), ; ignore failures
        FileSystem removeDirectory!("test/newly_created_dir"))
    )
  )

  describe("removeDirectory!",
    it("should signal an error if the directory doesn't exists",
      fn(FileSystem removeDirectory!("non_existing_dir")) should signal(Condition Error IO)
    )

    it("should signal an error if a file with the same name exists",
      fn(FileSystem removeDirectory!("build.xml")) should signal(Condition Error IO)
    )

    it("should remove the directory",
      FileSystem createDirectory!("test/dir_to_remove") ; set up
      FileSystem removeDirectory!("test/dir_to_remove")

      FileSystem should not have directory("test/dir_to_remove")
    )
  )
  
  describe("[]", 
    it("should glob correctly", 
      [
        [ [ "test/_test" ],                                 "test/_test" ],
        [ [ "test/_test/" ],                                "test/_test/" ],
        [ [ "test/_test/_file1", "test/_test/_file2" ],     "test/_test/*" ],
        [ [ "test/_test/_file1", "test/_test/_file2" ],     "test/_test/_file*" ],
        [ [  ],                                             "test/_test/frog*" ],
        
        [ [ "test/_test/_file1", "test/_test/_file2" ],     "test/**/_file*" ],
        
        [ [ "test/_test/_file1", "test/_test/_file2" ],     "test/_test/_file[0-9]*" ],
        [ [ ],                                              "test/_test/_file[a-z]*" ],
        
        [ [ "test/_test/_file1", "test/_test/_file2" ],     "test/_test/_file{0,1,2,3}" ],
        [ [ ],                                              "test/_test/_file{4,5,6,7}" ],
        
        [ [ "test/_test/_file1", "test/_test/_file2" ],     "test/**/_f*[il]l*" ],    
        [ [ "test/_test/_file1", "test/_test/_file2" ],     "test/**/_f*[il]e[0-9]" ],
        [ [ "test/_test/_file1"              ],             "test/**/_f*[il]e[01]" ],
        [ [ "test/_test/_file1"              ],             "test/**/_f*[il]e[01]*" ],
        [ [ "test/_test/_file1"              ],             "test/**/_f*[^ie]e[01]*" ],
        ] each(theList,
        FileSystem[theList second] should == theList first
      )
    )
  )
)
