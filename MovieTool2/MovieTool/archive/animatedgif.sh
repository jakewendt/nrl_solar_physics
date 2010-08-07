#!/bin/sh



/net/cronus/opt/bin/whirlgif -o $1 -loop $2 -time 5 *.gif





#          $WHIRLGIF -o ../ImageDir.$$.gif -loop 1 -time 5 *.gif
#         echo "" > /tmp/email.$$.html
#         echo "The LASCO/EIT animated gif that you created is ready at ... " >> /tmp/email.$$.html
#         echo "http://lasco-www.nrl.navy.mil/MovieTool/ImageDir.$$.gif" >> /tmp/email.$$.html
#         echo "" >> /tmp/email.$$.html
#         echo "ThanX for choosing LASCO/EIT for all your space weather needs." >> /tmp/email.$$.html
#         echo "" >> /tmp/email.$$.html
#         /usr/ucb/mail -s "LASCO/EIT animated gif is ready." jakewendt@nrl.navy.mil < /tmp/email.$$.html
#         /bin/rm /tmp/email.$$.html
#          ;;
#     AGIFL)
#          $WHIRLGIF -o ../ImageDir.$$.gif -loop -time 5 *.gif
#         echo "" > /tmp/email.$$.html
#         echo "The LASCO/EIT animated gif that you created is ready at ... " >> /tmp/email.$$.html
#         echo "http://lasco-www.nrl.navy.mil/MovieTool/ImageDir.$$.gif" >> /tmp/email.$$.html
#         echo "" >> /tmp/email.$$.html
#         echo "ThanX for choosing LASCO/EIT for all your space weather needs." >> /tmp/email.$$.html
#         echo "" >> /tmp/email.$$.html
#         /usr/ucb/mail -s "LASCO/EIT animated gif is ready." jakewendt@nrl.navy.mil < /tmp/email.$$.html
#         /bin/rm /tmp/email.$$.html
#          ;;

