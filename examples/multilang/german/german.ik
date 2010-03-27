
GermanDefaultBehavior = Reflector other:mimic(DefaultBehavior)
 
GermanDefaultBehavior imitator = cell(:mimic)
GermanDefaultBehavior imitiere = cell(:mimic!)
GermanDefaultBehavior wenn = cell(:if)
GermanDefaultBehavior ja = cell(:true)
GermanDefaultBehavior nein = cell(:false)

GermanDefaultBehavior methode = cell(:method)
GermanDefaultBehavior funktion = cell(:fn)
GermanDefaultBehavior Ursprung = Origin
GermanDefaultBehavior mache = cell(:do)
GermanDefaultBehavior mit = cell(:with)
GermanDefaultBehavior selbst = method(self)
GermanDefaultBehavior drucke = Origin cell(:print)
GermanDefaultBehavior druckeZeile = Origin cell(:println)
 
DefaultBehavior mimic!(GermanDefaultBehavior)
